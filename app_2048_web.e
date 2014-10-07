note
	description: "[
						This class implements the `Hello World' service.
		
						It inherits from WSF_DEFAULT_RESPONSE_SERVICE to get default EWF connector ready
						only `response' needs to be implemented.
						In this example, it is redefined and specialized to be WSF_PAGE_RESPONSE
		
						`initialize' can be redefine to provide custom options if needed.
	]"

class
	APP_2048_WEB

inherit

	WSF_DEFAULT_RESPONSE_SERVICE
		redefine
			initialize
		end

create
	make_and_launch

feature
	controller: CONTROLLER_2048
	is_attached : BOOLEAN
	status: STRING -- play , login, newuser
	password : STRING
	user : USER_2048

feature {NONE} -- Execution





    file_to_string (path: STRING): STRING
	local
    	l_file: PLAIN_TEXT_FILE
    	l_content: STRING
  	do
    	create l_file.make_open_read (path)
    	l_file.read_stream (l_file.count)
    	l_content := l_file.last_string.twin
    	l_file.close
    	Result := l_content
  	end

	response (req: WSF_REQUEST): WSF_HTML_PAGE_RESPONSE
			-- Computed response message.

		do

			create Result.make

			--TODO: Download the http://code.jquery.com/jquery-latest.min.js and call locally


			if status.is_equal ("login") then
					--TODO: Download the http://gabrielecirulli.github.io/2048/style/main.css and call locally
					Result.set_body ("<link rel='stylesheet' type='text/css' href='http://localhost:8000/login.css'>"  +
							file_to_string("login.js")
							)
					if (attached req.string_item ("user") as u) and (attached req.string_item ("pwd") as pass) then
						login(u.string,pass.string)
					end
					if user = void then
							Result.add_javascript_content ("alert('Invalid nickname or password')")
					else
						status := "play"
					end
			end
			if status.is_equal ("newuser") then

			end

			if status.is_equal ("play") then
				Result.add_javascript_content (file_to_string("jquery.js"))
				Result.add_javascript_content("function getChoice(keyCode){var ret='';if (keyCode == 119)ret = 'w';if (keyCode == 115)ret = 's';if (keyCode == 100)ret = 'd';if (keyCode == 97)ret = 'a';return ret;}")
				Result.add_javascript_content ("$(document).keypress(function (e) {var key = getChoice(e.keyCode);if(key != ''){$.ajax({type : 'POST',url:'http://localhost:9999/',data:{user:key},contentType:'json',headers: {Accept : 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8','Content-Type': 'application/x-www-form-urlencoded'}}).done(function(data){document.open();document.write(data);document.close();})}})")
				Result.set_body ("<link rel='stylesheet' type='text/css' href='http://localhost:8000/main.css'>" +
																	controller.board.out
																	)

				if attached req.string_item ("user") as l_user then


					if l_user.is_equal ("w") then
						if controller.board.can_move_up then
							controller.up
						end
					end
					if l_user.is_equal ("s") then
						if controller.board.can_move_down then
							controller.down
						end
					end
					if l_user.is_equal ("a") then
						if controller.board.can_move_left then
							controller.left
						end
					end
					if l_user.is_equal ("d") then
						if controller.board.can_move_right then
							controller.right
						end
					end
					if controller.board.is_winning_board then
						Result.add_javascript_content ("alert('YOU WON!!!!!!!!!!!!!!')")
					end

					if not controller.board.can_move_up and not controller.board.can_move_down and not controller.board.can_move_left and not controller.board.can_move_right then
						Result.add_javascript_content ("alert('YOU LOST!!!!!!!!!!!!!!')")
					end
					--TODO: Download the http://gabrielecirulli.github.io/2048/style/main.css and call locally
					Result.set_body ("<link rel='stylesheet' type='text/css' href='http://localhost:8000/main.css'>" +
														controller.board.out
														)
				end



			end

				--| note:
				--| 1) Source of the parameter, we could have used
				--|		 req.query_parameter ("user") to search only in the query string
				--|		 req.form_parameter ("user") to search only in the form parameters
				--| 2) response type
				--| 	it could also have used WSF_PAGE_REPONSE, and build the html in the code
				--|

		end


feature {NONE} -- Initialization

	initialize
		do
			--| Uncomment the following line, to be able to load options from the file ewf.ini
			status := "login"
			create controller.make
			create {WSF_SERVICE_LAUNCHER_OPTIONS_FROM_INI} service_options.make_from_file ("ewf.ini")

				--| You can also uncomment the following line if you use the Nino connector
				--| so that the server listens on port 9999
				--| quite often the port 80 is already busy
				--			set_service_option ("port", 9999)

				--| Uncomment next line to have verbose option if available
				--			set_service_option ("verbose", True)

				--| If you don't need any custom options, you are not obliged to redefine `initialize'
			Precursor
		end

feature --login

	login (username: STRING; pass: STRING)
			-- validate the user datas
			-- load the user from the file into the user variable, or void if the user doesn't exist
		require
			(create {USER_2048}.make_for_test).is_valid_nickname (username) and pass /= Void
		local
			possible_user: USER_2048
		do
			create possible_user.make_with_nickname (username)
			if possible_user.has_unfinished_game then
				possible_user.load_game
				if equal(pass, possible_user.password) then
					user := possible_user
				else
					user := Void
				end
			else
				user := Void
			end
		end
end
