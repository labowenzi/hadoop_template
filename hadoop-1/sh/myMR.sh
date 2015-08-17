#/bin/sh

# the var
shDir=`dirname "$0"`
shDir=`cd "$shDir" > /dev/null; pwd`
srcDir="$shDir""/../src"
classesDir="$shDir""/../classes"
jarDir="$shDir""/../jar"
inputDir="$shDir""/../input"
outputDir="$shDir""/../output"

hdfs_inputDir="/home/hadoop/test/input"
hdfs_output="/home/hadoop/test/output"

srcFile="Hw2Part1.java"
inputFile="wordcount.big.txt"
jarFile="ict.acs.hw2.jar"
mainClass="ict.acs.hw2.Hw2Part1"

hadoop_1_home="/home/hadoop/bin/hadoop"

# add hadoop libs to CLASSPATH
hadoop_1_jarDir="$hadoop_1_home"
if [ -d $hadoop_1_jarDir ]; then
  for f in "$hadoop_1_jarDir"/*.jar ; do
   CLASSPATH="$CLASSPATH":$f;
  done
fi
hadoop_1_jarDir="$hadoop_1_home""/lib"
if [ -d $hadoop_1_jarDir ]; then
  for f in "$hadoop_1_jarDir"/*.jar ; do
   CLASSPATH="$CLASSPATH":$f;
  done
fi

# cmd: all gen run clean put
if [ "$#" = 0 ]; then
  echo "Usage: myMR.sh cmd"
  echo "cmd is one of:"
  echo "  gen     generate jar file from the src file"
  echo "  clean   remove the output dir of this job from hdfs"
  echo "  put     put the data file to hdfs from local"
  echo "  get     get the output dir of this job from hdfs"
  echo "  show    cat the result of this job"
  echo "  run     remove the output dir from hdfs and run this job"
  echo "  all     = gen + clean + run"
  exit 1
fi

# genMR
#ls "$srcDir""/""$srcFile"
if [ "$1" == "all" -o "$1" == "gen" ]; then
  echo "all or gen: ""$1";
  javac -cp "$CLASSPATH" -d "$classesDir""/" "$srcDir""/""$srcFile";
  jar -cvf "$jarDir""/""$jarFile" -C "$classesDir" .;
fi

# cleanMR
if [ "$1" == "all" -o "$1" == "run" -o "$1" == "clean" ]; then
  echo "all or run or clean: ""$1";
  hadoop fs -rmr "$hdfs_output"/"$inputFile"
  echo "hadoop fs -ls ""$hdfs_output/$inputFile"" : "
  hadoop fs -ls "$hdfs_output"/"$inputFile"
fi

# putMR
if [ "$1" == "put" ]; then
  echo "put: ""$1";
  hadoop fs -rmr "$hdfs_inputDir"/"$inputFile"
  echo "hadoop fs -ls ""$hdfs_inputDir/$inputFile"" : "
  hadoop fs -ls "$hdfs_inputDir"/"$inputFile"
  hadoop fs -copyFromLocal "$inputDir"/"$inputFile" "$hdfs_inputDir"
  echo "hadoop fs -ls ""$hdfs_inputDir/$inputFile"" : "
  hadoop fs -ls "$hdfs_inputDir"/"$inputFile"
fi

# runMR
if [ "$1" == "all" -o "$1" == "run" ]; then
  echo "all or run: ""$1";
  echo "starting hadoop job. logging to "\
"$outputDir/$inputFile.output.1.txt"" and "\
"$outputDir/$inputFile.output.2.txt"
  hadoop jar "$jarDir"/"$jarFile" "$mainClass" "$hdfs_inputDir"/"$inputFile" \
"$hdfs_output"/"$inputFile" 2>"$outputDir"/"$inputFile".output.2.txt \
1>"$outputDir"/"$inputFile".output.1.txt
  echo "hadoop job: done."
fi

# mvMR

# getMR
if [ "$1" == "get" ]; then
  echo "get: ""$1";
  echo "hadoop fs -ls ""$hdfs_output/$inputFile"
  hadoop fs -ls "$hdfs_output"/"$inputFile"
  hadoop fs -copyToLocal "$hdfs_output"/"$inputFile" "$outputDir"/
  echo "ls -l ""$outputDir/$inputFile"
  ls -l "$outputDir"/"$inputFile"
fi

# showMR
if [ "$1" == "show" ]; then
  echo "show: ""$1";
  echo "hadoop fs -ls ""$hdfs_output/$inputFile"
  hadoop fs -ls "$hdfs_output"/"$inputFile"
  echo "hadoop fs -cat ""$hdfs_output/$inputFile/part-*"
  hadoop fs -cat "$hdfs_output"/"$inputFile"/"part-*"
fi


