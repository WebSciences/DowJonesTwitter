package groupproject;



import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.io.*;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import twitter4j.Status;
import twitter4j.TwitterException;
import twitter4j.TwitterObjectFactory;
import edu.stanford.nlp.ling.*;
import edu.stanford.nlp.neural.rnn.RNNCoreAnnotations;
import edu.stanford.nlp.pipeline.*;
import edu.stanford.nlp.sentiment.SentimentCoreAnnotations;
import edu.stanford.nlp.trees.*;
import edu.stanford.nlp.util.*;

public class Test {
	
	//get the date of each tweet 
	public String getdate(Status s){
		String d = null;
		Date dateObj = s.getCreatedAt();
		d = String.format("%d/%d",dateObj.getDate(),(dateObj.getMonth()+1));//get month is beginning from 0.
		return d;
	}
	
	//get each tweet
	public String gettweets(Status s){
		String tweet = null;
		tweet = s.getText();
		return tweet;
	}
	
	//get English tweets
	public boolean getlang(Status s){
		boolean lang = false;
		if(s.getLang().equals("en"))
			lang = true;
		return lang;
	}
	
	//find ibm,intel and ge company, give them a number
	public int norcompany(Status s){
		int num = 0;
		String tweet = gettweets(s).toLowerCase();//transfer all the tweet into lower letter		
		if(tweet.contains(" ibm ")||tweet.contains(" ibm.")||tweet.contains(" ibm,"))
			num = 1;
		else if(tweet.contains(" intel ")||tweet.contains(" intel.")||tweet.contains(" intel,"))
			num = 2;
		else if(tweet.contains("general electric"))
			num =3;
		return num;
	}
	
	//search the IBM with stock symbol
	public boolean stockIBM(Status s){
		boolean stock = false;
		String tweet = gettweets(s).toLowerCase();
		if(tweet.contains("$ibm"))
			stock = true;
		return stock;
	}
	
	//search the Intel with stock symbol
	public boolean stockIntel(Status s){
		boolean stock = false;
		String tweet = gettweets(s).toLowerCase();
		if(tweet.contains("$intc"))
			stock = true;
		return stock;
	}
	
	//search the GE with stock symbol
	public boolean stockGE(Status s){
		boolean stock = false;
		String tweet = gettweets(s).toLowerCase();
		if(tweet.contains("$ge"))
			stock = true;
		return stock;
	}
	
	static enum Output {
	    PENNTREES, VECTORS, ROOT, PROBABILITIES
	  }
	
	public int sentiment(Status s){
		int score = -1;
		// We initialize the StanfordCoreNLP class to process standard text input.
				Properties props = new Properties();
				props.setProperty("ssplit.eolonly", "true");
				props.setProperty("annotators", "tokenize, ssplit, parse, sentiment");
		        	      
				// Each line will be treated as a single sentence.
				List<Output> outputFormats = Arrays.asList(new Output[] { Output.ROOT });
				StanfordCoreNLP pipeline = new StanfordCoreNLP(props);
				
				// We test the systems speed
//				System.out.println(new Date( ) + "\n");
//		        for (int k = 0; k < 100; k++) {
		        	int label = -1;
			        //String line = "I was very fond of that movie. It had perfect speed and good characters.";
			        //regex to replace all the html links and hash-tag # 
		        	String line = s.getText();
			        String regEX = "([http|https]+[://]+[0-9A-Za-z:/[-]_#[?][=][.][&]]*)|#";
					Pattern pat = Pattern.compile(regEX);
					Matcher mat = pat.matcher(line);
					String newline = mat.replaceAll("");
					newline = newline.trim();
			        if (newline.length() > 0) {
			          Annotation annotation = pipeline.process(line);
			          for (CoreMap sentence : annotation.get(CoreAnnotations.SentencesAnnotation.class)) {
			        	    Tree tree = sentence.get(SentimentCoreAnnotations.AnnotatedTree.class);
			        	    for (Output output : outputFormats) {
			        	    	switch (output) {
			        	        	case ROOT: {
			        	        	    CoreLabel cl = (CoreLabel) tree.label();
			        	        	    cl.setValue(Integer.toString(RNNCoreAnnotations.getPredictedClass(tree)));
			        	        	    label = Integer.parseInt(cl.value()); // Takes values 0=Very negative 1=negative, 2=neutral, 3=positive, and 4=very positive
			        	        	    //System.out.println("Label is: " + label);
			        	        		break;
			        	        	}
			        	        	default:
			        	        		break;
		        	          	}
			        	    }
			          }
			        }
			        
			        // The result is now stored in label.
//			      }
		score = label;
		return score;
	}
	
	
	public void analysetweets(String s, String a){
		//hashmap store the results
		HashMap<String, ArrayList<Integer>> results = new HashMap<String, ArrayList<Integer>>();// keys=days+companynumber, value=[companynumber, very positive tweets... very negative tweets]
		Status tline = null;
		String filename = s;
		String dest = a;
		File infile = new File(filename);
		File outfile = new File(dest);
		try{
			//read file data
			BufferedReader reader = new BufferedReader(new FileReader(infile));
			BufferedWriter writer  = new BufferedWriter(new FileWriter(outfile));
			String line = null;
			int count = 0;
			while((line=reader.readLine()) != null){
				System.out.println(count++);
//				if (line.trim().length() == 0) continue;
				try {
					tline = TwitterObjectFactory.createStatus(line);//create a new status for analysis
				} catch(Exception e) { continue; }
				//first, judge the language, we only need the english tweets.
				if(getlang(tline)){
					String date = getdate(tline);
					int comnum = norcompany(tline);
					String key = date+", "+String.valueOf(comnum)+", ";//combine the date and company number together as the key of the hashmap
					//if there not exist a arraylist with the key
					if(!results.containsKey(key)){
						ArrayList<Integer> IBMlist = new ArrayList<Integer>();//new arrylist for IBM
						for(int i=0;i<10;i++){
							IBMlist.add(i, 0);
    	    			}
						ArrayList<Integer> Intellist = new ArrayList<Integer>();
						for(int i=0;i<10;i++){
							Intellist.add(i, 0);
    	    			}
						ArrayList<Integer> GElist = new ArrayList<Integer>();
						for(int i=0;i<10;i++){
							GElist.add(i, 0);
    	    			}
						//organize the tweets into different arraylist
						switch(norcompany(tline)){
						//IBM = 1
						case 1:
							if(stockIBM(tline)){
								// Takes values 0=$verynegative, 1=$negative, 2=$neutral, 3=$positive, 4=$verypositive, 5=verynegative, 6=negative, 7=neutral, 8=positive, 9=verypositive
								IBMlist.set(sentiment(tline),1);
							}else{
								IBMlist.set(sentiment(tline)+5,1);
							}							
							results.put(key, IBMlist);
						//Intel = 2
						case 2:
							if(stockIntel(tline)){
								// Takes values 0=$verynegative, 1=$negative, 2=$neutral, 3=$positive, 4=$verypositive, 5=verynegative, 6=negative, 7=neutral, 8=positive, 9=verypositive
								Intellist.set(sentiment(tline),1);
							}else{
								Intellist.set(sentiment(tline)+5,1);
							}
							results.put(key, Intellist);
						//GE = 3
						case 3:
							if(stockGE(tline)){
								// Takes values 0=$verynegative, 1=$negative, 2=$neutral, 3=$positive, 4=$verypositive, 5=verynegative, 6=negative, 7=neutral, 8=positive, 9=verypositive
								GElist.set(sentiment(tline),1);
							}else{
								GElist.set(sentiment(tline)+5,1);
							}
							results.put(key, GElist);
						} 
					}
					// if the key has existed
					else{
						switch(norcompany(tline)){
						//reset the value of IBM =1
						case 1:
							ArrayList<Integer> IBMlist = results.get(key);
							if(stockIBM(tline)){
								IBMlist.set(sentiment(tline),IBMlist.get(sentiment(tline))+1);
							}else{
								IBMlist.set(sentiment(tline)+5,IBMlist.get(sentiment(tline)+5)+1);
							}
	    	    			results.put(key, IBMlist);
	    	    		//reset the value of Intel =2
						case 2:
							ArrayList<Integer> Intellist = results.get(key);
							if(stockIntel(tline)){
								Intellist.set(sentiment(tline),Intellist.get(sentiment(tline))+1);
							}else{
								Intellist.set(sentiment(tline)+5,Intellist.get(sentiment(tline)+5)+1);
							}
	    	    			results.put(key, Intellist);
	    	    		//reset the value of Intel =2
						case 3:
							ArrayList<Integer> GElist = results.get(key);
							if(stockGE(tline)){
								GElist.set(sentiment(tline),GElist.get(sentiment(tline))+1);
							}else{
								GElist.set(sentiment(tline)+5,GElist.get(sentiment(tline)+5)+1);
							}
	    	    			results.put(key, GElist);
						}						
					}
				}
			}
			//write the result into the new file
			Iterator<String> iterator = results.keySet().iterator();  
            String l = null;
            String fr = null;
            while (iterator.hasNext()) {  
                l = iterator.next();
                fr = l+results.get(l);
                writer.write(fr);  
                writer.newLine();  
                writer.flush();
            }
			reader.close();
			writer.close();
		} catch (FileNotFoundException e) {  
		    e.printStackTrace();  
		} catch (IOException e) {  
		    e.printStackTrace();  
		}
	}
	
	
	public static void main(String[] args){
		Test test = new Test();
		String in = "C:\\Users\\Elvis\\Desktop\\group project\\data\\outputData\\testsl.txt";
		String out = "C:\\Users\\Elvis\\Desktop\\group project\\data\\stanford_out.txt";
		test.analysetweets(in, out);
	}

}
