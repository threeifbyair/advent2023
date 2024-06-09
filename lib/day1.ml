let rec find_first_last a b l = match (a, b, l) with
   (None, _, []) | (_, None, []) -> failwith "Found no digits!"
  | (None, Some _, _ :: _) | (Some _, None, _ :: _) -> failwith "What the bleep!"
  | (Some x, Some y, []) -> 10 * x + y
  | (Some x, Some y, ch :: ll) -> find_first_last (Some x) (Some (if ch >= '0' && ch <= '9' then (int_of_char ch - int_of_char '0') else y)) ll
  | (None, None, ch :: ll) -> let digit = match ch with | '0'..'9' -> Some (int_of_char ch - int_of_char '0') | _ -> None in find_first_last digit digit ll


let process_line line = 
  find_first_last None None (List.of_seq (String.to_seq line))


let day1 input_lines part_two _ _ = 
  if part_two then
    failwith "Part two not done yet!"
  else
    let line_list = (List.map process_line input_lines) in 
      let sum = List.fold_left ( + ) 0 line_list in
        print_endline (string_of_int sum)
