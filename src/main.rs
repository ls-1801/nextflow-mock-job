use std::fs;
use clap::{Parser, ArgEnum};
use crate::Runtime::{Linear, NLogN, Quadratic};
use core::arch::x86_64::_rdtsc;
use std::fs::OpenOptions;
use std::io::Write;

#[derive(Debug, Copy, Clone, PartialEq, Eq, PartialOrd, Ord, ArgEnum)]
enum Runtime {
    Constant,
    Linear,
    NLogN,
    Quadratic,
    Terrible,
}

#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
struct Args {
    #[clap(long, arg_enum)]
    runtime: Runtime,

    #[clap(long, default_value_t = 1.0)]
    runtime_factor: f64,

    #[clap(long)]
    input: Vec<String>,

    #[clap(long, )]
    output: Option<String>,

    #[clap(long)]
    n_output: Option<u64>,

    #[clap(long, default_value_t = 1.0)]
    output_ratio: f64,

}


fn main() {
    let instructions = unsafe { _rdtsc() };
    let args = Args::parse();
    let input_size = do_stuff(args).unwrap();
    let instructions = unsafe { _rdtsc() } - instructions;
    println!("({input_size}, {instructions})");
}

fn do_stuff(args: Args) -> std::io::Result<usize> {

    let mut inputs_size = 0usize;

    for input in args.input.iter() {
        let input = fs::read(input)?;
        inputs_size = inputs_size + input.len();
        let target_size = (input.len() as f64 * args.output_ratio) as usize;
        let mut output = vec![0; target_size];

        let mut index = 0usize;

        if args.runtime == NLogN {
            output.copy_from_slice(input.as_slice());
            output.sort();
        }else{
            for _ in 0..args.runtime_factor.floor() as usize {
                for (idx, byte) in input.iter().enumerate() {
                    if idx % (target_size / 10) == 0 {
                        // println!("Progress: {}", idx as f64 / target_size as f64)
                    }
                    if args.runtime == Linear {
                        output[index % target_size] = *byte;
                        continue;
                    }

                    for byte in input.iter() {
                        if args.runtime == Quadratic {
                            output[index % target_size] = *byte;
                            continue;
                        }

                        for byte in input.iter() {
                            output[index % target_size] = *byte;
                        }
                    }
                }
            }
        }


        if let Some(ref output_file) = args.output {

            if let Some(number_of_output_files) = args.n_output {
                for i in 0..number_of_output_files {
                    let mut file = OpenOptions::new()
                        .append(true)
                        .create(true)
                        .open(format!("{output_file}{i}"))
                        .unwrap();
                    file.write_all(&output)?;
                }
            } else {
                let mut file = OpenOptions::new()
                    .append(true)
                    .create(true)
                    .open(output_file)
                    .unwrap();
                file.write_all(&output)?;
            }
        }
    }

    Ok(inputs_size)
}
