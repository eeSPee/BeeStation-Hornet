//#define TESTING				//By using the testing("message") proc you can create debug-feedback for people with this
								//uncommented, but not visible in the release version)

//#define DATUMVAR_DEBUGGING_MODE	//Enables the ability to cache datum vars and retrieve later for debugging which vars changed.

// Comment this out if you are debugging problems that might be obscured by custom error handling in world/Error
#ifdef DEBUG
#define USE_CUSTOM_ERROR_HANDLER
#endif

#ifdef TESTING
#define DATUMVAR_DEBUGGING_MODE

//#define GC_FAILURE_HARD_LOOKUP	//makes paths that fail to GC call find_references before del'ing.
									//implies FIND_REF_NO_CHECK_TICK

//#define FIND_REF_NO_CHECK_TICK	//Sets world.loop_checks to false and prevents find references from sleeping


//#define VISUALIZE_ACTIVE_TURFS	//Highlights atmos active turfs in green
#endif

//#define UNIT_TESTS			//If this is uncommented, we do a single run though of the game setup and tear down process with unit tests in between

#ifndef PRELOAD_RSC				//set to:
#define PRELOAD_RSC	0			//	0 to allow using external resources or on-demand behaviour;
#endif							//	1 to use the default behaviour;
								//	2 for preloading absolutely everything;

#ifdef LOWMEMORYMODE
#define FORCE_MAP "_maps/runtimestation.json"
#endif

//Update this whenever you need to take advantage of more recent byond features
#define MIN_COMPILER_VERSION 513
#define MIN_COMPILER_BUILD 1514
#if DM_VERSION < MIN_COMPILER_VERSION || DM_BUILD < MIN_COMPILER_BUILD
//Don't forget to update this part
#error Your version of BYOND is too out-of-date to compile this project. Go to https://secure.byond.com/download and update.
<<<<<<< HEAD
#error You need version 513.1514 or higher
=======
#error You need version 513.1514 or higher.
>>>>>>> upstream/master
#endif

//Update this whenever the byond version is stable so people stop updating to hilariously broken versions
#define MAX_COMPILER_VERSION 513
#define MAX_COMPILER_BUILD 1536
#if DM_VERSION > MAX_COMPILER_VERSION || DM_BUILD > MAX_COMPILER_BUILD
#warn WARNING: Your BYOND version is over the recommended version (513.1536)! Stability is not guaranteed.
#endif


//Additional code for the above flags.
#ifdef TESTING
#warn compiling in TESTING mode. testing() debug messages will be visible.
#endif

#ifdef GC_FAILURE_HARD_LOOKUP
#define FIND_REF_NO_CHECK_TICK
#endif

#ifdef CIBUILDING
#define UNIT_TESTS
#endif

#ifdef CITESTING
#define TESTING
#endif

#define EXTOOLS (world.system_type == MS_WINDOWS ? "byond-extools.dll" : "libbyond-extools.so")
