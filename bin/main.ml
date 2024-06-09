(* main.ml for Advent of Code 2023 *)

let read_whole_chan chan =
  let lines = ref [] in
  let rec loop () =
    let line = input_line chan in
      lines := line :: !lines;
      loop ()
  in
    try loop () with
      End_of_file -> List.rev !lines

let read_whole_file filename =
  let chan = match filename with | "" | "-" -> Stdlib.stdin | _ -> open_in filename in
    read_whole_chan chan

let part_two = ref false
let verbose = ref false
let input_file = ref ""
let cmdline_arg = ref 0
let extra_args = ref []

let extraarg_processor arg = extra_args := int_of_string arg :: !extra_args

let usage_msg = "advent2023 [-v] [-p] [-i <file>] [-a arg] day [day] [day]"

let speclist = [
  ("-p", Arg.Set part_two, "Perform part two of the challenge");
  ("-v", Arg.Set verbose, "Give verbose results");
  ("-i", Arg.Set_string input_file, "The file to read input from");
  ("-a", Arg.Set_int cmdline_arg, "The command-line argument, if any")
]

let pick_fn day = match day with
  | 1 -> Advent2023.Day1.day1 
  | _ -> failwith "Unknown day!"

let do_day lines day = (pick_fn day) lines !part_two !verbose !cmdline_arg

let () = 
  let () = Arg.parse speclist extraarg_processor usage_msg in
    let input_lines = read_whole_file !input_file in
      List.iter (do_day input_lines) !extra_args 
