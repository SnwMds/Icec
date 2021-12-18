import argparse

parser = argparse.ArgumentParser(
    prog="icec",
    description="Icec is a command-line based source client for the Icecast streaming server",
    allow_abbrev=False,
    epilog="Note, options that take an argument require a colon. E.g. --username:USERNAME"
)

parser.add_argument(
	"-v",
    "--version",
    action="store_true",
    help = "show version number and exit"
)

server_section = parser.add_argument_group(
	title = "Server"
)

server_section.add_argument(
    "--address",
    help = "address to connect to. [default: 127.0.0.1]"
)


server_section.add_argument(
    "--port",
    help = "port to connect to. [default: 8000]"
)

server_section.add_argument(
    "--mount-point",
    help = "mount point to send data to. [default: /stream]"
)

authentication_section = parser.add_argument_group(
	title = "Authentication"
)

authentication_section.add_argument(
    "--username",
    help = "set source username. [default: source]"
)

authentication_section.add_argument(
    "--password",
    help = "set source password. [default: hackme]"
)

media_streaming_section = parser.add_argument_group(
	title = "Stream"
)

media_streaming_section.add_argument(
    "--yp-policy",
    help = "set whether or not the mount point shoult be advertised to a YP directory. [default: 0]",
    metavar = "POLICY"
)

media_streaming_section.add_argument(
    "--name",
    help = "set name of the stream"
)

media_streaming_section.add_argument(
    "--description",
    help = "set description of the stream"
)

media_streaming_section.add_argument(
    "--url",
    help = "set url of the stream"
)

media_streaming_section.add_argument(
    "--genre",
    help = "set genre of the stream"
)

media_streaming_section.add_argument(
    "--bitrate",
    help = "set bitrate of the stream"
)

media_streaming_section.add_argument(
    "--audio-info",
    help = "set a key-value list of audio information about the stream",
    metavar = "INFO"
)

media_streaming_section.add_argument(
    "--content-type",
    help = "set content type of the stream. [default: audio/mpeg]",
    metavar = "TYPE"
)

media_streaming_section.add_argument(
    "--shuffle",
    action = "store_true",
    help="shuffle items of the playlist"
)

media_streaming_section.add_argument(
    "--repeat",
    action = "store_true",
    help="repeat the playlist when it ends"
)

media_streaming_section.add_argument(
    "--repeat-max",
    help = "repeat the playlist at n times (requires --repeat)",
    metavar = "N"
)

configuration_section = parser.add_argument_group(
	title = "Configuration"
)

configuration_section.add_argument(
    "--config-file",
    help = "read configuration from a .cfg file instead of command-line arguments",
    metavar = "FILE"
)

parser.add_argument(
	", ".join({"<media-uri>", "<media-path>"}),
	type=open,
	nargs = "*"
)

print("Saving to ./help_message.txt")

with open(file = "./help_message.txt", mode = "w") as file:
	parser.print_help(file = file)