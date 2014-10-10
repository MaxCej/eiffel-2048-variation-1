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
	WSF_ROUTED_SERVICE

--	WSF_DEFAULT_RESPONSE_SERVICE
	WSF_DEFAULT_SERVICE
		redefine
			initialize
		end

create
	make_and_launch

feature
	controller: CONTROLLER_2048
	is_attached : BOOLEAN
	password : STRING
	user : USER_2048

feature {NONE} -- Execution


	setup_router
	do
		map_agent_uri ("/login", agent login_screen, Void)
		map_agent_uri ("/signin", agent signin_screen, Void)
		map_agent_uri ("/play", agent play, Void)
	end

feature -- Helper: mapping
	map_agent_uri (a_uri: READABLE_STRING_8; a_action: like {WSF_URI_AGENT_HANDLER}.action; rqst_methods: detachable WSF_REQUEST_METHODS)
	do
		router.map_with_request_methods (create {WSF_URI_MAPPING}.make (a_uri, create {WSF_URI_AGENT_HANDLER}.make (a_action)), rqst_methods)
	end


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

	--response (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Computed response message.
--		local
--				html: WSF_HTML_PAGE_RESPONSE
--				redir: WSF_HTML_DELAYED_REDIRECTION_RESPONSE
--				s: STRING_8
--				l_username: STRING_32

--		do
--				create Result.make


			--TODO: Download the http://code.jquery.com/jquery-latest.min.js and call locally


					--TODO: Download the http://gabrielecirulli.github.io/2048/style/main.css and call locally
--					s := "<p>Hello there!</p>"
--					s.append (file_to_string("login.js"))
--					s.append ("<p>Register <a href=%"/signin/%">here</a>!</p>")
--					Result.set_body ("<link rel='stylesheet' type='text/css' href='http://localhost:8000/login.css'>"  +
--							s
--							)
--					if (attached req.string_item ("user") as u) and (attached req.string_item ("pwd") as pass) then
--						login(u.string,pass.string)
--						if user = Void then
--							Result.add_javascript_content ("alert('Invalid nickname or password')")
--						else
--							status := "play"
--						end

--					end



				--| note:
				--| 1) Source of the parameter, we could have used
				--|		 req.query_parameter ("user") to search only in the query string
				--|		 req.form_parameter ("user") to search only in the form parameters
				--| 2) response type
				--| 	it could also have used WSF_PAGE_REPONSE, and build the html in the code
				--|

--		end


feature {NONE} -- Initialization

	initialize
		do
			--| Uncomment the following line, to be able to load options from the file ewf.ini
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
				initialize_router
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


	create_user (name:STRING; surname:STRING; nickname:STRING; pass:STRING)
	--Read the user data
	--Create a new user
	local
		valid_data : BOOLEAN
		new_user : USER_2048
	do
		create new_user.make_for_test
		valid_data := False
			if new_user.is_valid_name (name) and new_user.is_valid_name (surname) and new_user.is_valid_name (nickname) and new_user.is_valid_password (pass) then --validate the data
				if not  new_user.existing_file (nickname) then
					valid_data := True
				end
			end


		if valid_data then
			create new_user.make_new_user (name, surname,nickname,pass)
			user := new_user
		end

	end

feature -- tal vez las rutas no estan tan buenas
	signin_screen(req: WSF_REQUEST; res: WSF_RESPONSE)
	local
		mesg: WSF_HTML_PAGE_RESPONSE
	do
		create mesg.make
		mesg.set_body ("<link rel='stylesheet' type='text/css' href='http://localhost:8000/signin.css'>"  +
						file_to_string("signin.js") + "<p><a href=%"/login/%">go back</a></p>"
						)
		if (attached req.string_item ("name") as na) and (attached req.string_item ("surname") as sur) and(attached req.string_item ("nick") as ni) and (attached req.string_item ("pass") as pa) then
			create_user(na,sur,ni,pa)
			if user/= Void then
				mesg.add_javascript_content ("alert('User created succesfully')")
				mesg.set_body ("<link rel='stylesheet' type='text/css' href='http://localhost:8000/login.css'>"+"<p> <a href=%"/play/%">PLAY</a></p>")
			else
				mesg.add_javascript_content ("alert('Invalid data, please ensure to enter the data correctly')")
			end
		end
		res.send (mesg)
	end

	login_screen(req: WSF_REQUEST; res: WSF_RESPONSE)
	local
		mesg: WSF_HTML_PAGE_RESPONSE
		s: STRING_8
		l_username: STRING_32

	do
		user:=Void
		create controller.make
		create mesg.make
		--TODO: Download the http://code.jquery.com/jquery-latest.min.js and call locally
		--TODO: Download the http://gabrielecirulli.github.io/2048/style/main.css and call locally
		s := "<p>Hello there!</p>"
		s.append (file_to_string("login.js"))
		s.append ("<p>Register <a href=%"/signin/%">here</a>!</p>")
		mesg.set_body ("<link rel='stylesheet' type='text/css' href='http://localhost:8000/login.css'>"  + s)
		if (attached req.string_item ("user") as u) and (attached req.string_item ("pwd") as pass) then
			login(u.string,pass.string)
			if user = Void then
				mesg.add_javascript_content ("alert('Invalid nickname or password')")
			else
				user.load_game
				create controller.make_with_board (user.game)
				mesg.set_body ("<link rel='stylesheet' type='text/css' href='http://localhost:8000/login.css'>"+"<p> <a href=%"/play/%">PLAY</a></p>")
			end
		end
		res.send (mesg)
	end


	play(req:WSF_REQUEST;res: WSF_RESPONSE)
	local
		mesg: WSF_HTML_PAGE_RESPONSE
	do
			create mesg.make
			mesg.add_javascript_content (file_to_string("jquery.js"))
			mesg.add_javascript_content("function getChoice(keyCode){var ret='';if (keyCode == 119)ret = 'w';if (keyCode == 115)ret = 's';if (keyCode == 100)ret = 'd';if (keyCode == 97)ret = 'a';return ret;}")
			mesg.add_javascript_content ("$(document).keypress(function (e) {var key = getChoice(e.keyCode);if(key != ''){$.ajax({type : 'POST',url:'http://localhost:9999/play',data:{user:key},contentType:'json',headers: {Accept : 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8','Content-Type': 'application/x-www-form-urlencoded'}}).done(function(data){document.open();document.write(data);document.close();})}})")
			mesg.set_body ("<link rel='stylesheet' type='text/css' href='http://localhost:8000/main.css'>" +
																	controller.board.out + "<p> <a href=%"/login/%">Save and quit</a></p>"
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
					mesg.add_javascript_content ("alert('YOU WON!!!!!!!!!!!!!!')")
				end

				if not controller.board.can_move_up and not controller.board.can_move_down and not controller.board.can_move_left and not controller.board.can_move_right then
					mesg.add_javascript_content ("alert('YOU LOST!!!!!!!!!!!!!!')")
				end
				--TODO: Download the http://gabrielecirulli.github.io/2048/style/main.css and call locally
				mesg.set_body ("<link rel='stylesheet' type='text/css' href='http://localhost:8000/main.css'>" +
														controller.board.out + "<p> <a href=%"/login/%">Save and quit</a></p>"
														)
			end
			user.save_game (user.game)
			res.send (mesg)
	end

end
