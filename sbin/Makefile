all:
	cc -Wall -O6 -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -mcpu=pentiumpro -o encoder_0 encoder_0.c
	cc -Wall -O6 -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -mcpu=pentiumpro -o decoder_0 decoder_0.c
	cc -Wall -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -O6 -mcpu=pentiumpro -o splicer_0 splicer_0.c
	strip splicer_0 encoder_0 decoder_0

unoptimized:
	cc -Wall -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -o encoder_0 encoder_0.c
	cc -Wall -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -o splicer_0 splicer_0.c
