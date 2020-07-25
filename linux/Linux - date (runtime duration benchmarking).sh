#!/bin/bash

# ------------------------------------------------------------
# Simple Timestamp

DATETIMESTAMP="$(date +'%Y%m%d_%H%M%S')";

# ------------------------------------------------------------
# RFC-3339 Timestamp

DATETIMESTAMP="$(date --rfc-3339='seconds';)";


# ------------------------------------------------------------
# Simple Benchmark

BENCHMARK_START=$(date +'%s.%N');
sleep 3;
BENCHMARK_DELTA=$(echo "scale=4; ($(date +'%s.%N') - ${BENCHMARK_START})/1" | bc -l);
echo "  |--> Finished after ${BENCHMARK_DELTA}s";


# ------------------------------------------------------------
#
# 	Date-Time Vars
#		 |--> Make sure that the "date" command is called only once (e.g. make sure to only grab one timestamp)
#		      This way, we can format it however we want without concern of inaccuracies existing between multiple date/timestamp values
#
#
START_SECONDS_NANOSECONDS=$(date +'%s.%N');
START_EPOCHSECONDS=$(echo ${START_SECONDS_NANOSECONDS} | cut --delimiter '.' --fields 1);
START_NANOSECONDS=$(echo ${START_SECONDS_NANOSECONDS} | cut --delimiter '.' --fields 2 | cut --characters 1-9);
START_MICROSECONDS=$(echo ${START_NANOSECONDS} | cut --characters 1-6);
START_MILLISECONDS=$(echo ${START_NANOSECONDS} | cut --characters 1-3);
START_DATETIME="$(date --date=@${START_EPOCHSECONDS} +'%Y-%m-%d %H:%M:%S')";
START_TIMESTAMP="$(date --date=@${START_EPOCHSECONDS} +'%Y%m%d_%H%M%S')";
START_TIMESTAMP_FILENAME="$(date --date=@${START_EPOCHSECONDS} +'%Y-%m-%d_%H-%M-%S')";
START_TIMESTAMP_COMPACT="$(date --date=@${START_EPOCHSECONDS} +'%Y%m%d%H%M%S')";
START_SECONDS="$(date --date=@${START_EPOCHSECONDS} +'%s')";
START_FRACTION_SECONDS="$(date --date=@${START_EPOCHSECONDS} +'%N')";
DATE_AS_YMD="$(date --date=@${START_EPOCHSECONDS} +'%Y%m%d')";
TODAY_AS_WEEKDAY="$(date --date=@${START_EPOCHSECONDS} +'%a')";


# Command here...
sleep 0.5; # Example command - sleep half a second


END_TIMESTAMP=$(date +'%s.%N');
END_EPOCHSECONDS=$(echo ${END_TIMESTAMP} | cut --delimiter '.' --fields 1);
END_MILLISECONDS=$(echo ${END_TIMESTAMP} | cut --delimiter '.' --fields 2 | cut --characters 1-3);
END_MICROSECONDS=$(echo ${END_TIMESTAMP} | cut --delimiter '.' --fields 2 | cut --characters 1-6);
END_DATETIME=$(date --date=@${START_EPOCHSECONDS} +'%Y-%m-%d %H:%M:%S');

END_DATETIME="$(date +'%Y-%m-%d %H:%M:%S')";


TOTAL_DECIMALSECONDS=$(echo "${END_TIMESTAMP} - ${START_TIMESTAMP}" | bc)

TOTAL_EPOCHSECONDS=$(printf '%d' $(echo ${TOTAL_DECIMALSECONDS} | cut --delimiter '.' --fields 1));
TOTAL_MILLISECONDS=$(printf '%d' $(echo ${TOTAL_DECIMALSECONDS} | cut --delimiter '.' --fields 2 | cut --characters 1-3));
TOTAL_MICROSECONDS=$(printf '%d' $(echo ${TOTAL_DECIMALSECONDS} | cut --delimiter '.' --fields 2 | cut --characters 1-6));

TOTAL_DURATION=$(printf '%02dh %02dm %02d.%06ds' $(echo "${TOTAL_EPOCHSECONDS}/3600" | bc) $(echo "(${TOTAL_EPOCHSECONDS}%3600)/60" | bc) $(echo "${TOTAL_EPOCHSECONDS}%60" | bc) $(echo ${TOTAL_MICROSECONDS}));

echo "\$START_TIMESTAMP = [${START_TIMESTAMP}]  ";
echo "\$END_TIMESTAMP = [${END_TIMESTAMP}]  ";

echo "\$TOTAL_DECIMALSECONDS = [${TOTAL_DECIMALSECONDS}]  ";

echo "\$TOTAL_EPOCHSECONDS = [${TOTAL_EPOCHSECONDS}]";
echo "\$TOTAL_MILLISECONDS = [${TOTAL_MILLISECONDS}]";
echo "\$TOTAL_MICROSECONDS = [${TOTAL_MICROSECONDS}]";

echo "Duration: ${TOTAL_DURATION}   (Ran [${START_DATETIME}] to [${END_DATETIME}])";


# ------------------------------------------------------------