note
	description: "Test class for routine make_empty at BOARD_2048."
	author: "jpadula"
	date: "August 28, 2014"
	revision: "0.01"

class
	MAKE_EMPTY_AT_BOARD_2048

inherit
	EQA_TEST_SET

feature

	make_empty_qty_columns_correct
		-- qty_columns_correct testing that the Quantity of Cells be the correct
		local
			board : BOARD_2048
		do
			create board.make_empty
			assert("QTY Cells correct",board.elements.count = 16)
		end

	make_empty_all_are_default_values
		-- all_are_default_values testing that all elements of the board are the default cell (0)
		local
			board : BOARD_2048
			i : INTEGER
			j : INTEGER
			flag : BOOLEAN
		do
			create board.make_empty
			flag := True
			from
				i := 1
			until
				i > 4
			loop
				from
					j := 1
				until
					j > 4
				loop
					if board.elements.item (i,j).value /= 0 then
						flag := False
					end
					j := j+1
				end
				i := i+1
			end
			assert("All default values", flag = True)
		end

end
