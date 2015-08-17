/*  5,201418013229031,马文龙 */
package ict.acs.hw2;

import java.io.IOException;
import java.util.Iterator;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

public class Hw2Part1 {

	public static class Map extends
			Mapper<LongWritable, Text, Text, IntWritable> {

		// 实现map函数

		public void map(LongWritable key, Text value, Context context)

		throws IOException, InterruptedException {

			// 将输入的纯文本文件的数据转化成String

			String line = value.toString();

			// 将输入的数据首先按行进行分割

			StringTokenizer tokenizerArticle = new StringTokenizer(line, "\n");

			// 分别对每一行进行处理

			while (tokenizerArticle.hasMoreElements()) {

				// 每行按空格划分

				StringTokenizer tokenizerLine = new StringTokenizer(
						tokenizerArticle.nextToken());

				String strSource = tokenizerLine.nextToken();// source 部分
				String strDestination= tokenizerLine.nextToken();// Destination 部分
				String strTime= tokenizerLine.nextToken();// time部分

				Text tkey = new Text(strSource+" "+strDestination);
				int scoreInt = Integer.parseInt(strTime);

				// 输出姓名和成绩

				context.write(tkey, new IntWritable(scoreInt));

			}

		}

	}

	public static class Reduce extends

	Reducer<Text, IntWritable, Text, IntWritable> {

		// 实现reduce函数

		public void reduce(Text key, Iterable<IntWritable> values,

		Context context) throws IOException, InterruptedException {
			int sum = 0;
			int count = 0;
			Iterator<IntWritable> iterator = values.iterator();

			while (iterator.hasNext()) {

				sum += iterator.next().get();// 计算总分

				count++;// 统计总的科目数

			}
	    	int av=(int) sum / count;
	    	key.set(key.toString()+"******"+String.valueOf(count));
		 	 context.write(key, new IntWritable(av));
		}

	}

	public static void main(String[] args) throws Exception {

		Configuration conf = new Configuration();

		// 这句话很关键

		conf.set("mapred.job.tracker", "localhost:9001");

		String[] otherArgs = new GenericOptionsParser(conf, args)
				.getRemainingArgs();

		if (otherArgs.length != 2) {

			System.err.println("Usage: Score Average <in> <out>");

			System.exit(2);

		}

		Job job = new Job(conf, "Score Average");

		job.setJarByClass(Hw2Part1.class);

		// 设置Map、Combine和Reduce处理类

		job.setMapperClass(Map.class);

    // combiner?
		//job.setCombinerClass(Reduce.class);

		job.setReducerClass(Reduce.class);

		// 设置输出类型

		job.setOutputKeyClass(Text.class);

		job.setOutputValueClass(IntWritable.class);

		// 将输入的数据集分割成小数据块splites，提供一个RecordReder的实现

		job.setInputFormatClass(TextInputFormat.class);

		// 提供一个RecordWriter的实现，负责数据输出

		job.setOutputFormatClass(TextOutputFormat.class);

		// 设置输入和输出目录

		FileInputFormat.addInputPath(job, new Path(otherArgs[0]));

		FileOutputFormat.setOutputPath(job, new Path(otherArgs[1]));

		System.exit(job.waitForCompletion(true) ? 0 : 1);

	}

}
