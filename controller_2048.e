note
	description: "This class takes care of the control of the game."
	author: ""
	date: "August 25, 2014"
	revision: "0.01"

class
	CONTROLLER_2048

create
	make, make_with_board

feature -- Initialisation

	make_with_board (new_board: BOARD_2048)
			-- Creates a controller with reference to a provided board
		require
			new_board /= Void
		do
			board := new_board
		ensure
			board = new_board
		end

	make
			-- Creates a controller from scratch. The controller must create the
			-- classes that represent and take care of the logic of the game.

		do
			coord_last_random_cell := [0, 0]
			create board.make
		ensure
			board /= Void
		end

feature {ANY}

	coord_last_random_cell: TUPLE [INTEGER, INTEGER]
			-- Tuple containing the coordinates of the last random cell.

feature -- Game State

	board: BOARD_2048
			-- Reference to the object that maintains the state of the game
			-- and takes care of the games logic.

	is_finished: BOOLEAN
			-- Indicates whether the game is finished or not.
			-- Game finishes when either 2048 is reached, or if there is no possible movement.
		local
			finished: BOOLEAN -- Auxiliary variable to capture the finalization desicion
		do
			finished := False
			if not board.can_move_up and not board.can_move_down and not board.can_move_left and not board.can_move_right then
				finished := True
			else
				finished := board.is_winning_board
			end
			Result := finished
		end

	last_random_cell_coordinates: TUPLE [INTEGER, INTEGER]
			-- Returns the coordinates of th last randomly introduced
			-- cell. Value should be (0,0) if no cell has been introduced in the last movement
			-- or if the game state is the initial state.
		do
			Result := coord_last_random_cell
		end

feature -- Movement commands

	up
			-- Moves the cells to the uppermost possible point of the game board.
			-- Movement colapses cells with the same value.
			-- It adds one more random cell with value 2 or 4, after the movement.
		require
			board.can_move_up
		local
			i, k, j: INTEGER
		do
				--First I add the cells that can be added
			from
				j := 1
			until
				j > 4
			loop
				from
					i := 1
				until
					i >= 4
				loop
					if board.elements.item (i, j).value /= 0 then
						k := i + 1;
						from
								-- search for the next element /= 0
						until
							(k > 4) or (board.elements.item (k, j).value /= 0)
						loop
							k := k + 1;
						end
						if (k <= 4) then
							if (board.elements.item (i, j).value = board.elements.item (k, j).value) then
								board.set_cell (i, j, (board.elements.item (k, j).value // 2))
								board.set_cell (k, j, 0)
								i := k + 1
							else
								i := k
							end
						else
							i := k
						end
					else
						i := i + 1
					end
				end --end loop i
				j := j + 1
			end --end loop j
				-- occupy available cells at the top.
			from --
				j := 1
			until
				j > 4
			loop
				from
					i := 1
				until
					i >= 4
				loop
					if board.elements.item (i, j).value = 0 then
						k := i + 1;
						from
								-- search for the next element /= 0
						until
							(k > 4) or (board.elements.item (k, j).value /= 0)
						loop
							k := k + 1;
						end
						if (k <= 4) then
							board.set_cell (i, j, board.elements.item (k, j).value)
							board.set_cell (k, j, 0)
							i := i + 1
						else
							i := k
						end
					else
						i := i + 1
					end
				end --end loop i
				j := j + 1
			end --end loop j
			set_random_free_cell
		end --end do

	down -- Moves the cells to the lowermost possible point of the game board.
			-- Movement colapses cells with the same value.
			-- It adds one more random cell with value 2 or 4, after the movement.
		require
			board.can_move_down
		local
			i, j, aux: INTEGER
		do
				-- add all possible cells downward
			from -- columns
				i := 1
			until
				i > 4
			loop
				from -- rows (from the lowermost to the uppermost row)
					j := 4
				until
					j <= 1
				loop
					if board.elements.item (j, i).value /= 0 then
						aux := j;
						j := j - 1;
						from
								-- search for the next element /= 0
						until
							(j < 1) or (board.elements.item (j, i).value /= 0)
						loop
							j := j - 1;
						end
						if j >= 1 then -- if search is succesful
							if board.elements.item (aux, i).value = board.elements.item (j, i).value then
								board.set_cell (aux, i, (board.elements.item (aux, i).value // 2))
								board.set_cell (j, i, 0)
								j := j - 1;
							end
						end
					else
						j := j - 1;
					end -- end if /=0
				end -- end loop j
				i := i + 1;
			end -- end loop i

				--occupy all empty spaces downward
			from -- columns
				i := 1
			until
				i > 4
			loop
				from -- rows (from the lowermost to the uppermost row)
					j := 4
				until
					j = 1
				loop
					if ((board.elements.item (j, i).value = 0) and (board.elements.item (j - 1, i).value) /= 0) then -- if j,i = 0 and the one above it is =/ 0
						board.set_cell (j, i, board.elements.item (j - 1, i).value)
						board.set_cell (j - 1, i, 0)
						if (j < 4) then --if not at the lowermost cell
							j := j + 1; -- continues moving downward until it reaches an ocupied cell
						else
							j := j - 1; -- continues moving upward
						end
					else
						j := j - 1;
					end
				end -- end loop j
				i := i + 1;
			end -- end loop i
			set_random_free_cell
		end -- end do

	left
			-- Moves the cells to the leftmost possible point of the game board.
			-- Movement colapses cells with the same value.
			-- It adds one more random cell with value 2 or 4, after the movement.
		require
			board.can_move_left
		local
			i, j, k: INTEGER
		do
			from
				i := 1
			until
				i > 4
			loop
				from
					j := 1
				until
					j >= 4
				loop
					if board.elements.item (i, j).value /= 0 then
						k := j + 1
						from
						until
							(k > 4) or (board.elements.item (i, k).value /= 0)
						loop
							k := k + 1
						end
						if (k <= 4) then
							if (board.elements.item (i, j).value = board.elements.item (i, k).value) then
								board.set_cell (i, j, (board.elements.item (i, k).value // 2))
								board.set_cell (i, k, 0)
								j := k + 1
							else
								j := k
							end -- end if
						else
							j := k
						end
					else
						j := j + 1
					end -- end if /=0
				end --end loop j
				i := i + 1
			end --end loop i

			from --
				i := 1
			until
				i > 4
			loop
				from
					j := 1
				until
					j >= 4
				loop
					if (board.elements.item (i, j).value = 0) and (board.elements.item (i, j + 1).value /= 0) then
						board.set_cell (i, j, board.elements.item (i, j + 1).value)
						board.set_cell (i, j + 1, 0)
						if (j = 1) then --if at the leftrmost cell
							j := j + 1; -- continues moving to the right until it reaches an occupied cell
						else
							j := j - 1; -- continues moving left
						end
					else
						j:= j + 1
					end -- end if
				end --end loop j
				i := i + 1
			end --end loop i
			set_random_free_cell
		end --end do	

	right
			-- Moves the cells to the rightmost possible point of the game board.
			-- Movement colapses cells with the same value.
			-- It adds one more random cell with value 2 or 4, after the movement.

		require
			board.can_move_right
		local
			i, j, k, v: INTEGER
		do
			from
				i := 1
			until
				i > 4
			loop
				from
					j := 4
				until
					j <= 1
				loop
					if board.elements.item (i, j).value /= 0 then
						if j > 1 then
							k := j - 1
							from
							until
								(k <= 1) or (board.elements.item (i, k).value /= 0)
							loop
								k := k - 1
							end
							if (k >= 1) then
								if (board.elements.item (i, j).value = board.elements.item (i, k).value) then
									board.set_cell (i, j, (board.elements.item (i, k).value // 2))
									board.set_cell (i, k, 0)
									j := k - 1
								else
									j := k
								end
							end
						end
					else
						j := j - 1
					end
				end --end loop j
				i := i + 1
			end --end loop i

			from --
				i := 1
			until
				i > 4
			loop
				from
					j := 4
				until
					j < 1
				loop
					if board.elements.item (i, j).value /= 0 then
						v := board.elements.item (i, j).value
						board.set_cell (i, j, 0)
						position_right (i, v)
						j := j - 1;
					else
						j := j - 1
					end --end if
				end --end loop j
				i := i + 1
			end --end loop i
			set_random_free_cell
		end --end do

feature {NONE} -- Auxiliary routines

	position_right (row, val: INTEGER)
			-- Method that receives as a parameter a row, and verifies the position which is more to the right
			-- which is empty in that row and also inserts the value passed as parameter
		local
			column: INTEGER
		do
			from
				column := 4
			until
				column < 1
			loop
				if board.elements.item (row, column).value = 0 then
					board.set_cell (row, column, val)
					column := 0
				else
					column := column - 1
				end --end if
			end --end loop
		end --end do

	random_number_two_or_four (random_sequence: RANDOM): INTEGER
			-- Randomly returns two or four
		local
			random_number: INTEGER
		do
			random_number := (get_random (random_sequence, 2) + 1) * 2
			Result := random_number * 256
		ensure
			Result = 512 or Result = 1024
		end

	get_random_seed: INTEGER
			-- Returns a seed for random sequences
		local
			l_time: TIME
			l_seed: INTEGER
		do
			create l_time.make_now
			l_seed := l_time.hour
			l_seed := l_seed * 60 + l_time.minute
			l_seed := l_seed * 60 + l_time.second
			l_seed := l_seed * 1000 + l_time.milli_second
			Result := l_seed
		end

	get_random (random_sequence: RANDOM; ceil: INTEGER): INTEGER
			-- Returns a random integer minor that ceil from a random sequence
		require
			ceil >= 0
		do
			random_sequence.forth
			Result := random_sequence.item \\ ceil;
		ensure
			Result < ceil
		end

Feature {SET_RANDOM_FREE_CELL_AT_CONTROLLER}
set_random_free_cell
		require
			not board.is_full
		local
		    random_sequence : RANDOM
			random_cell_row : INTEGER
			random_cell_col : INTEGER
		do
			--initialize random seed
		    create random_sequence.set_seed(get_random_seed)
			random_cell_row := get_random(random_sequence, 4) + 1;
			random_cell_col := get_random(random_sequence, 4) + 1;
		    from
		    until
		    	board.elements.item(random_cell_row, random_cell_col).is_available = True
		    loop
		    	--generate a random position
				random_cell_row := get_random(random_sequence, 4) + 1;
				random_cell_col := get_random(random_sequence, 4) + 1;
		    end
			-- set at cell random number
			board.set_cell(random_cell_row, random_cell_col, random_number_two_or_four(random_sequence))
			coord_last_random_cell := [random_cell_row,random_cell_col]
		end

end
