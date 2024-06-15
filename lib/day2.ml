type rgb = { red: int; green: int; blue: int }



let rec process_subgame verbose part_two gameid maxrgb l = 
  let re = Str.regexp {|\([0-9]+\)+ \([a-z]+\)|} in 
    let check_rgb num color maxrgb = 
      if verbose then Printf.printf "Processing %d %s\n" num color; 
      match color with 
      | "red" -> if num <= maxrgb.red then 1 else 0
      | "green" -> if num <= maxrgb.green then 1 else 0
      | "blue" -> if num <= maxrgb.blue then 1 else 0
      | _ -> failwith "Unknown color!"
    in
        match l with 
        | [] -> 1
        | cmd :: ll -> if Str.string_match re cmd 0 then
                        let num = Str.matched_group 1 cmd in
                          let color = Str.matched_group 2 cmd in 
          (check_rgb (int_of_string num) color maxrgb) * (process_subgame verbose part_two gameid maxrgb ll)
        else failwith "Not a color!"






let rec find_subgame verbose part_two gameid maxrgb l = 
    match l with
    | [] -> gameid
    | game :: ll -> if verbose then Printf.printf("Game %d: %s\n") gameid game; (process_subgame verbose part_two gameid maxrgb (Str.split (Str.regexp ", ") game)) * find_subgame verbose part_two gameid maxrgb ll 

let process_game part_two verbose line =
  let re = Str.regexp {|^Game \([0-9]+\): \(.+\)$|} in 
    if Str.string_match re line 0 then 
      let gameid = int_of_string (Str.matched_group 1 line) in 
        let gamestr = Str.matched_group 2 line in 
          let games = Str.split (Str.regexp "; ") gamestr in 
            find_subgame verbose part_two gameid {red = 12; green = 13; blue = 14} games  
    else failwith "Not a game!"


 let process_day2_line part_two verbose line = 
  let result = process_game part_two verbose line in
    if verbose then Printf.printf "Result: %d\n" result;
    result

let day2 input_lines part_two verbose _ = 
  let line_list = (List.map (process_day2_line part_two verbose) (List.filter (fun l -> String.length l > 0) input_lines)) in 
    let sum = List.fold_left ( + ) 0 line_list in
      print_endline (string_of_int sum)
