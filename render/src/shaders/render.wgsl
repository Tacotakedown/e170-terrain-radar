struct LatLon {
    lat: f32;
    lon: f32;
};

struct Uniform {
    map_center: LatLon;
    [[align(16)]] vertical_diameter: f32;
    aspect_ratio: f32;
    tile_size: u32;
    heading: f32;
    altitude: f32;
};

struct TileStatus {
    values: array<u32>;
};

[[group(0), binding(0)]]
var<uniform> uniforms: Uniform;
[[group(0), binding(1)]]
var tile_map: texture_2d<u32>;
[[group(0), binding(2)]]
var<storage, read_write> tile_status: TileStatus;
[[group(0), binding(3)]]
var tile_atlas: texture_2d<u32>;
[[group(0), binding(4)]]
var hillshade_atlas: texture_2d<f32>;

var<private> l500: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l1000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l2000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l3000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l4000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l5000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l6000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l7000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l8000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l9000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l10000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l11000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l12000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l13000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l15000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l17000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l19000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l21000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> l33000: vec3<f32> = vec3<f32>(0.00, 0.00, 0.00);
var<private> unknown_terrain: vec3<f32> = vec3<f32>(0.41, 0.15, 0.42);
var<private> water: vec3<f32> = vec3<f32>(0.49,0.65,0.73);
var<private> taws_med_green: vec3<f32> = vec3<f32>(0.06,0.36,0.14);
var<private> taws_green: vec3<f32> = vec3<f32>(0.19,0.64,0.30);
var<private> taws_orange: vec3<f32> = vec3<f32>(0.76,0.53,0.10);
var<private> taws_yellow: vec3<f32> = vec3<f32>(0.96, 0.98, 0.01);
var<private> taws_red: vec3<f32> = vec3<f32>(0.96, 0.00, 0.00);
var<private> rand_seed : vec2<f32>;



fn degrees(radians: f32) -> f32 {
    return radians * 57.295779513082322865;
}

fn project(uv: vec2<f32>) -> LatLon {
    let headsin = sin(uniforms.heading);
    let headcos = cos(uniforms.heading);
    let offset_uv = vec2<f32>(uv.x - 0.5, uv.y - 0.5);
    let scaled_uv = vec2<f32>(offset_uv.x * uniforms.aspect_ratio, offset_uv.y);
    let rotated_uv = vec2<f32>(scaled_uv.x * headcos - scaled_uv.y * headsin, scaled_uv.x * headsin + scaled_uv.y * headcos);
    let uv = vec2<f32>(rotated_uv.x + 0.5, rotated_uv.y + 0.5);
    let xy = (uv - vec2<f32>(0.5, 0.5)) * uniforms.vertical_diameter;

    let latsin = sin(uniforms.map_center.lat);
    let latcos = cos(uniforms.map_center.lat);
    let c = sqrt(xy.x * xy.x + xy.y * xy.y);
    let csin = sin(c);
    let ccos = cos(c);

    let lat = asin(ccos * latsin + xy.y * csin * latcos / c);
    let lon = uniforms.map_center.lon + atan2(xy.x * csin, c * latcos * ccos - xy.y * latsin * csin);

    return LatLon(lat, lon);
}

fn map_height(height: u32) -> vec3<f32> {
    let feet = i32(f32(i32(height) - 500) * 3.28084);
    if (feet - 2000 > i32(uniforms.altitude)) {
        return taws_red;
    }else if(feet - 1000 > i32(uniforms.altitude)) {
        return taws_orange;
    }else if (feet > i32(uniforms.altitude - 500.0)) {
        return taws_yellow;
    } else if(feet + 1000 > i32(uniforms.altitude)) {
        return taws_med_green;
    }else if(feet + 2000 > i32(uniforms.altitude)) {
        return taws_green;
    }else if (feet < 500) {
        return l500;
    } else {
        switch (feet / 1000) {
            case 0: { return l1000; }
            case 1: { return l2000; }
            case 2: { return l3000; }
            case 3: { return l4000; }
            case 4: { return l5000; }
            case 5: { return l6000; }
            case 6: { return l7000; }
            case 7: { return l8000; }
            case 8: { return l9000; }
            case 9: { return l10000; }
            case 10: { return l11000; }
            case 11: { return l12000; }
            case 12: { return l13000; }
            case 13: { return l15000; }
            case 14: { return l15000; }
            case 15: { return l17000; }
            case 16: { return l17000; }
            case 17: { return l19000; }
            case 18: { return l19000; }
            case 19: { return l21000; }
            case 20: { return l21000; }
            case 21: { return l33000; }
            case 22: { return l33000; }
            case 23: { return l33000; }
            case 24: { return l33000; }
            case 25: { return l33000; }
            case 26: { return l33000; }
            case 27: { return l33000; }
            case 28: { return l33000; }
            case 29: { return l33000; }
            case 30: { return l33000; }
            case 31: { return l33000; }
            case 32: { return l33000; }
            default: { return unknown_terrain; }
        }
    }
}

struct SampleResult {
    height: u32;
    hillshade: f32;
};

fn sample_globe(lat: f32, lon: f32) -> SampleResult {
    let tile_loc = vec2<u32>(u32(lon), u32(lat));
    let index = tile_loc.y * 360u + tile_loc.x;
    tile_status.values[index] = 1u;
    let tile_offset = vec2<i32>(textureLoad(tile_map, vec2<i32>(tile_loc), 0)).xy;

    let atlas_dimensions = textureDimensions(tile_atlas, 0);
    let not_found = tile_offset.x == i32(atlas_dimensions.x);
    let unloaded = tile_offset.y == i32(atlas_dimensions.y);

    if (not_found) {
        return SampleResult(1u << 15u, 1.0);
    } else if (unloaded) {
        return SampleResult(1u << 15u, 0.0);
    } else {
        let tile_uv = vec2<f32>(lon - floor(lon), 1.0 - (lat - floor(lat)));
        let pixel = vec2<f32>(tile_offset) + tile_uv * f32(uniforms.tile_size);

        let height = textureLoad(tile_atlas, vec2<i32>(pixel), 0).x;
        let hillshade = textureLoad(hillshade_atlas, vec2<i32>(pixel), 0).x;
        return SampleResult(height, mix(0.4, 1.0, hillshade));
    }
}

[[stage(fragment)]]
fn main([[location(0)]] uv: vec2<f32>) -> [[location(0)]] vec4<f32> {
    let rad_position = project(uv);
    let lat = degrees(rad_position.lat) + 90.0;
    var lon = (degrees(rad_position.lon) + 180.0) % 360.0;
    if (lon < 0.0) {
        lon = lon + 360.0;
    }

    let tile_uv = vec2<f32>(lon - floor(lon), 1.0 - (lat - floor(lat)));
    let pixel = tile_uv * f32(uniforms.tile_size);
    let pixel_offset = pixel - floor(pixel);

    let delta = 1.0 / f32(uniforms.tile_size);
    let x = sample_globe(lat, lon);
    let y = sample_globe(lat, lon + delta);
    let z = sample_globe(lat - delta, lon);
    let w = sample_globe(lat - delta, lon + delta);

    let xh = f32(~(1u << 15u) & x.height);
    let yh = f32(~(1u << 15u) & y.height);
    let zh = f32(~(1u << 15u) & z.height);
    let wh = f32(~(1u << 15u) & w.height);

    let xl_lerp = mix(xh, yh, pixel_offset.x);
    let xh_lerp = mix(zh, wh, pixel_offset.x);
    let height = u32(mix(xl_lerp, xh_lerp, pixel_offset.y));


    let xw = f32((x.height >> 15u) & 1u);
    let yw = f32((y.height >> 15u) & 1u);
    let zw = f32((z.height >> 15u) & 1u);
    let ww = f32((w.height >> 15u) & 1u);

    let xl_lerp = mix(xw, yw, pixel_offset.x);
    let xh_lerp = mix(zw, ww, pixel_offset.x);
    let is_water = mix(xl_lerp, xh_lerp, pixel_offset.y);

    let xl_lerp = mix(x.hillshade, y.hillshade, pixel_offset.x);
    let xh_lerp = mix(z.hillshade, w.hillshade, pixel_offset.x);
    let hillshade = mix(xl_lerp, xh_lerp, pixel_offset.y);

    var ret: vec3<f32>;
    if (is_water > 0.5) {
        ret = water;
    } else {
        ret = map_height(height);
    }
    return vec4<f32>(pow(ret, vec3<f32>(2.2)), 1.0);
}
