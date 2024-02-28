extern crate rustler;
extern crate kmeans_colors;
extern crate image;
extern crate palette;

use rustler::{Env, NifResult, Term};
use kmeans_colors::{get_kmeans, Kmeans, MapColor, Sort};
use palette::{FromColor, IntoColor, Lab, Srgb};
use image::io::Reader as ImageReader;
use image::GenericImageView;
use image::{open, Pixel};
use reqwest;
use std::io::Read;

#[rustler::nif]
fn find_dominant_colors(env: Env, image_path: String, k: usize, runs: usize, max_iter: usize, converge: f32, seed: u64) -> NifResult<Vec<(u8, u8, u8)>> {
    // Load the image

    let mut response = match reqwest::blocking::get(&image_path) {
        Ok(resp) => resp,
        Err(e) => {
            println!("Erreur lors du téléchargement de l'image: {}. URL: {}", e, image_path);
            return Err(rustler::Error::Term(Box::new("Erreur lors du téléchargement de l'image")));
        },
    };

    let mut buf = Vec::new();
    match response.read_to_end(&mut buf) {
        Ok(_) => {},
        Err(e) => {
            println!("Erreur lors de la lecture de la réponse: {}. URL: {}", e, image_path);
            return Err(rustler::Error::Term(Box::new("Erreur lors de la lecture de la réponse")));
        },
    };

    let img = match image::load_from_memory(&buf) {
        Ok(img) => img.to_rgb8(),
        Err(e) => {
            println!("Erreur de décodage de l'image: {}. URL: {}", e, image_path);
            return Err(rustler::Error::Term(Box::new("Erreur de décodage de l'image")));
        },
    };

    // Convert RGB [u8] buffer to Lab for k-means
    let lab: Vec<Lab> = img.pixels()
        .map(|p| Srgb::new(p[0] as f32 / 255.0, p[1] as f32 / 255.0, p[2] as f32 / 255.0).into_color())
        .collect();

    // Perform k-means clustering
    let mut best_result: Option<Kmeans<Lab>> = None;
    for i in 0..runs {
        let run_result = get_kmeans(k, max_iter, converge, false, &lab, seed + i as u64);
        if best_result.as_ref().map_or(true, |best| run_result.score < best.score) {
            best_result = Some(run_result);
        }
    }
    let result = best_result.unwrap();

    // Convert centroids back to Srgb<u8> for output
    let rgb: Vec<(u8, u8, u8)> = result.centroids.iter()
        .map(|x| Srgb::from_color(*x).into_format())
        .map(|color| (color.red, color.green, color.blue))
        .collect();

    Ok(rgb)
}

rustler::init!("Elixir.TestWebscrapping.ImageAnalyzer", [find_dominant_colors]);
