/*
  FrameSyncronizer for playing video without breaks inbetween, 
  perfectly smooth transitions.

  Chris Kennedy, October 2003
*/

#include <unistd.h>
#include <features.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <inttypes.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <math.h>
#include <signal.h>
#include <time.h>

void play(int);
void cleanup(int);
int file_tstamp(char *);
int build_playlist(int);

//#define VIDEO_DEV "/opt/dvr/lock/dec_fifo"
#define VIDEO_DEV "/u1/Scratch/decode"
#define MAX_INPUT_LINE 256
#define SHOW_LINE_COUNT 0
#define VERBOSE 1
#define MAX_EVENTS 256
#define MAX_LINE 256
#define BLOCK "/opt/dvr/lock/bb_lock"
#define BLOCKLINK "/opt/dvr/lock/bb_lock_l"
#define PLOCK "/opt/dvr/lock/p_lock"
#define PLOCKLINK "/opt/dvr/lock/p_lock_l"
#define PLAYLIST "/opt/dvr/lock/playlist"

char *lock_link = NULL;
char *playlist[MAX_EVENTS];

int load_mpeg = 0;

int main(int argc, char *argv[])
{
  int line_count = 0;
  int fdout = -1, fdin = -1;
  char *line = NULL;
  int strsize, i, j;
  int seconds = 0;
  char *events[MAX_EVENTS];
  int event_count = 0;
  FILE *lck = NULL;
  pid_t pid;
  time_t now;

  /* get current UNIX time and PID */
  time(&now);
  pid = getpid();

  lock_link = malloc(23+7);
  if(lock_link == NULL)
    exit(1);
  snprintf(lock_link, 23+7,"%s.%d", BLOCKLINK, pid);
  printf("'%s.%d'\n", BLOCKLINK, pid);
  printf("'%s'\n", lock_link);

  signal(SIGPIPE,SIG_IGN);
  signal(SIGHUP,play);

  /*******************/
  /* Check Arguments */
  /*******************/
  if(argc > 1) {
    for(i = 1; argv[i] && (i <= argc); i++) {
      if((strncmp(argv[i], "-", 1) == 0
         && (strlen(argv[i]) == 1))) {
        exit(1);
      } else if((strncmp(argv[i], "-", 1) == 0) && (argv[i][1] == '\0'))
        continue;
      else if(strncmp(argv[i], "/", 1) == 0) {
        j = 0;
        while (i < MAX_EVENTS && argv[i] && (i <= argc) && 
	 strncmp(argv[i], "/", 1) == 0) {
          event_count++;
          if(VERBOSE)
            printf("File %3d: %s\n", event_count, argv[i]);
          strsize = strlen(argv[i]);
          events[j] = malloc(strsize + 1);
          events[j+1] = '\0'; 
          if(events[j] == NULL)
            continue;
          strncpy(events[j], argv[i], strsize + 1);
          j++; i++;
        }
        continue;
      } else {
        /* Play Time */
        for(j = 0; argv[i][j] != '\0'; j++) {
          if(isdigit(argv[i][j]) == 0) {
            /* Bad Argument Given */
            fprintf(stderr, "program: ERROR: bad option! %s\n", argv[i]);
            fprintf(stderr, "Usage: program [seconds] [mpegfile]\n");
            exit(1);
          }
        }
        seconds = (int) atoi(argv[i]);
        if(VERBOSE)
          printf("Playing for %d Seconds\n", seconds);
      }
    }
  } else {
    fprintf(stderr, "Usage: program [seconds] [mpegfile]\n");
    exit(1);
  }

  /* Time the Recording */
  alarm(seconds);

  /* Allocate input line */
  line = malloc(MAX_INPUT_LINE + 1);
  if(line == NULL)
    exit(1);

  /* Open Mpeg Output to fifo */
  if ( (fdout = open(VIDEO_DEV, O_TRUNC|O_WRONLY) ) < 0 ) {
    fprintf(stderr, "Failed to open %s: %s\n", VIDEO_DEV, strerror(errno));
    exit(1);
  }
  signal(SIGINT,cleanup);

  while(1) {
    /* Lock Video Output */
    lck = fopen(lock_link, "w");
    if(lck == NULL)
      return 1;

    if(link(lock_link, BLOCK) != 0) {
      fclose(lck);
      unlink(lock_link);
      return 1;
    } else
      fclose(lck);

    if(load_mpeg == 1) {
      int ret = 0;
      load_mpeg = 0;

      ret = build_playlist(0);
 
      /* Write Video Output from playlist */
      line_count = 0;
      for(i=0; ret == 0 && playlist[i] != NULL;i++) {
        if(VERBOSE)
          printf("\nPlaying %d: %s\n", i, playlist[i]);
        /* Open Video Input */
        if ( (fdin = open(playlist[i], O_RDONLY) ) < 0 ) {
          fprintf(stderr, "Failed to open '%s': %s\n", 
		playlist[i], strerror(errno));
          unlink(lock_link);
          unlink(BLOCK);
          break;
        }
        /* Read from Video Input while Writing to Output */
        while(read(fdin, line, MAX_INPUT_LINE) > 0) {
          /* Break out of loop when signal to play file is caught */
          if(load_mpeg == 1) {
            break;
          }
          line_count++;

          write(fdout, line, MAX_INPUT_LINE);

          if(SHOW_LINE_COUNT)
            printf("%d\n", line_count);
        }
        /* Close Input File */
        close(fdin);

        /* Break out of loop when signal to play file is caught */
        if(load_mpeg == 1) {
          break;
        }
      }
    } else {
      /* Write Video Output from command line */
      line_count = 0;
      for(i=0; events[i] != NULL;i++) {
        if(VERBOSE)
          printf("\nPlaying %d: %s\n", i, events[i]);
        /* Open Video Input */
        if ( (fdin = open(events[i], O_RDONLY) ) < 0 ) {
          fprintf(stderr, "Failed to open %s: %s\n", 
		events[i], strerror(errno));
          unlink(lock_link);
          unlink(BLOCK);
          exit(1);
        }
        /* Read from Video Input while Writing to Output */
        while(read(fdin, line, MAX_INPUT_LINE) > 0) {
          /* Break out of loop when signal to play file is caught */
          if(load_mpeg == 1) {
            break;
          }
          line_count++;

          write(fdout, line, MAX_INPUT_LINE);

          if(SHOW_LINE_COUNT)
            printf("%d\n", line_count);
        }
        /* Close Input File */
        close(fdin);

        /* Break out of loop when signal to play file is caught */
        if(load_mpeg == 1) {
          break;
        }
      }
    }

    /* Unlock Video Output */
    unlink(lock_link);
    unlink(BLOCK);
  }

  /* Close output to fifo */
  close(fdout);

  return 0;
}


void play(int signal)
{
  load_mpeg = 1;
  return;
}

int file_tstamp(char *filename)
{
  struct stat buf;

  if(stat(filename, &buf) == 0) {
    if(buf.st_mtime != 0)
      return buf.st_mtime;
  }
  return -1;
}

void cleanup(int signal)
{
  unlink(lock_link);
  unlink(BLOCK);
  exit(1);
}

int build_playlist(int input)
{
  FILE *file;
  char *line;
  int strsize, j = 0;
  int event_count = 0;

  /* Open playlist */
  file = fopen(PLAYLIST, "r");
  if(file == NULL)
    return 1;

  /* line buffer */
  line = (char *) malloc(MAX_LINE +1);
  if(line == NULL)
    return 1;

  while((fgets(line, MAX_LINE +1, file)) != NULL) {
    if(strncmp(line, "/", 1) == 0) {
      event_count++;
      if(VERBOSE)
        printf("Playlist File %3d: %s\n", event_count, line);
      strsize = strlen(line);
      playlist[j] = malloc(strsize + 1);
      playlist[j+1] = '\0'; 
      if(playlist[j] == NULL)
        continue;
      strncpy(playlist[j], line, strsize - 1);
      j++; 
    }
  }

  /* Close and delete playlist */
  fclose(file);
  //unlink(PLAYLIST);
  return 0;
}
