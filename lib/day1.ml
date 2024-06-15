
  let rec find_first_last p2 v a b l = 
    if v then Printf.printf "Got %d %d %d:\n" (match a with None -> -1 | Some x -> x) (match b with None -> -1 | Some x -> x) (List.length l);
    match (a, b, l) with
      (None, _, []) | (_, None, []) -> failwith "Found no digits!"
      | (None, Some _, _ :: _) | (Some _, None, _ :: _) -> failwith "What the bleep!"
      | (Some x, Some y, []) -> (if v then Printf.printf " Found end with %d %d\n\n" x y; 10 * x + y)

      (* In the below, digits can overlap, so we'd better make sure we keep the overlapping letters. *)
      | (x, _, 'o' :: 'n' :: 'e' :: ll) when p2 -> (if v then Printf.printf " Found one\n"; find_first_last p2 v (if x = None then Some 1 else x) (Some 1) ('e' :: ll))
      | (x, _, 't' :: 'w' :: 'o' :: ll) when p2 -> (if v then Printf.printf " Found two\n"; find_first_last p2 v (if x = None then Some 2 else x) (Some 2) ('o' :: ll))
      | (x, _, 't' :: 'h' :: 'r' :: 'e' :: 'e' :: ll) when p2 -> (if v then Printf.printf " Found three\n"; find_first_last p2 v (if x = None then Some 3 else x) (Some 3) ('e' :: ll))
      | (x, _, 'f' :: 'o' :: 'u' :: 'r' :: ll) when p2 -> (if v then Printf.printf " Found four\n"; find_first_last p2 v (if x = None then Some 4 else x) (Some 4) ll)
      | (x, _, 'f' :: 'i' :: 'v' :: 'e' :: ll) when p2 -> (if v then Printf.printf " Found five\n"; find_first_last p2 v (if x = None then Some 5 else x) (Some 5) ('e' :: ll))
      | (x, _, 's' :: 'i' :: 'x' :: ll) when p2 -> (if v then Printf.printf " Found six\n"; find_first_last p2 v (if x = None then Some 6 else x) (Some 6) ll)
      | (x, _, 's' :: 'e' :: 'v' :: 'e' :: 'n' :: ll) when p2 -> (if v then Printf.printf " Found seven\n"; find_first_last p2 v (if x = None then Some 7 else x) (Some 7) ll)
      | (x, _, 'e' :: 'i' :: 'g' :: 'h' :: 't' :: ll) when p2 -> (if v then Printf.printf "Found eight\n"; find_first_last p2 v (if x = None then Some 8 else x) (Some 8) ('t' :: ll))
      | (x, _, 'n' :: 'i' :: 'n' :: 'e' :: ll) when p2 -> (if v then Printf.printf " Found nine\n"; find_first_last p2 v (if x = None then Some 9 else x) (Some 9) ('e' :: ll))

      (* Now match other stuff -- either digits or stuff we're ignoring. *)
      | (Some x, Some y, ch :: ll) -> (if v then Printf.printf " Found letter %c (with front %d and back %d)\n" ch x y; (find_first_last p2 v (Some x) (Some (if ch >= '0' && ch <= '9' then (int_of_char ch - int_of_char '0') else y)) ll))
      | (None, None, ch :: ll) -> (if v then Printf.printf " Found letter %c (with nothing)\n" ch; (let digit = match ch with | '0'..'9' -> Some (int_of_char ch - int_of_char '0') | _ -> None in find_first_last p2 v digit digit ll))

 let process_line part_two verbose line = 
  find_first_last part_two verbose None None (List.of_seq (String.to_seq line))

  
let day1 input_lines part_two verbose _ = 
  let line_list = (List.map (process_line part_two verbose) (List.filter (fun l -> String.length l > 0) input_lines)) in 
    let sum = List.fold_left ( + ) 0 line_list in
      print_endline (string_of_int sum)
