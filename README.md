# NLP Code for Dynamic Network Lab Research


**NLP code repo for DNL research**


The visualizations in this Readme are based on sample decision data (N = 239) from DNL's Summer 2021 general decision calculator study.  
&nbsp;

### LDA Density Plots 

Below is an LDA density plot for the decisions that participants listed. The density plot provides one indication for the ideal number of topics in the text data. The density plot shows the probabilities of overlap of terms in topics for a particular solution. The lower the density (of overlap), the better the solution as low term overlap will help the researcher subjectively differentiate the topics and provide definitions for the topics based on their unique terms. 

![alt text](https://github.com/gzlupko/dnl_nlp/blob/main/topic_density_stemmed_plot.png)

Document term matrices can be created in R using the `tidytext` library and an LDA model can be created using the `topicmodels` library. Topic model density plots are generated using the `ldatuning` library.

The following code can be used to generate a density plot analyzing between `k = 2` to `k = 10` topics as was done above. 

&nbsp;
```
library(ldatuning)

seed<-90178933469
result.gibbs <- FindTopicsNumber(
  sample_dtm,
  topics = seq(from = 2, to = 10, by = 1),
  metrics = c("CaoJuan2009"),
  method = "GIBBS",
  
  control=list(seed = seed),
  mc.cores = 2L,
  verbose = TRUE
)

FindTopicsNumber_plot(result.gibbs)
```

&nbsp;





### Sample 3-Topic Solution
Below are the top terms for each of the three topics in the recommended three topic solution. 

![alt text](https://github.com/gzlupko/dnl_nlp/blob/main/reasons_stemmed_plot.png)


&nbsp;

&nbsp;

### Topic and Term Probabilities 
The below table shows the probabilities of each topic occuring in the corpus (overall collection of text data) as well as the the probability of each term occuring in the corpus. Note: this is based on a three-topic solution, which is recommended by the density statistic as well as a subjective content review of the groupings. 

![alt text](https://github.com/gzlupko/dnl_nlp/blob/main/beta_gamma_sample.png)



&nbsp;

&nbsp;

### N-gram Analyses 

N-gram analyses are used to understand which words are commonly used together in text (Finch et al., 2018). The below table shows bi-gram and tri-gram analyses of the decision data, indicating two and three word groupings that most commonly occur in the text data. 
 
 

![alt text](https://github.com/gzlupko/dnl_nlp/blob/main/sample_n-gram_analysis.png) 




&nbsp;

&nbsp;


The below table shows the most commonly occuring words that succeed target words from our topic model.

![alt text](https://github.com/gzlupko/dnl_nlp/blob/main/bi_gram_succeeding.png)



&nbsp;

&nbsp;


### Sentiment Analysis 

Below are word counts and associated sentiments for sample airline review Twitter data. 


![alt text](https://github.com/gzlupko/dnl_nlp/blob/main/sentiment_count.png)


&nbsp;

&nbsp;

### Hypothesis Testing with Sentiment Scores 


The table below shows results from a two proportion z-test on the difference of the proportion of positively valenced words in the reasons for data (N = 1,359) compared to the proportion of positively valenced words in the reasons against data (N = 1,297) 

![alt text](https://github.com/gzlupko/dnl_nlp/blob/main/two_proportions_positive.png)




&nbsp;

&nbsp;


### Correlations with Sentiment Scores and Other Variables 


Sentiment scores can be created at the sentence-level using the sentimentr library in R. Those scores can be used in subsequent analyses with other variables measured in cross-sectional research. The below correlation matrix shows the correlations between combined reason sentiment scores (e.g. all reasons combined into one long string) with other BRT variables like perceived control and global motives. 

![alt text](https://github.com/gzlupko/dnl_nlp/blob/main/reasons_corrplot.png)




