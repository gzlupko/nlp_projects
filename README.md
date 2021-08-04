# NLP Code for Dynamic Network Lab Research
NLP code repo for DNL research


Sample Decision Data (N = 239) 

### LDA Density Plots 

Below is an LDA density plot for the decisions that participants listed. The density plot provides one indication for the ideal number of topics in the text data. The density plot shows the probabilities of overlap of terms in topics for a particular solution. The lower the density (of overlap), the better the solution as low term overlap will help the researcher subjectively differentiate the topics and provide definitions for the topics based on their unique terms. 

![alt text](https://github.com/gzlupko/dnl_nlp/blob/main/topic_density_stemmed_plot.png)

### Sample 3-Topic Solution
Below are the top terms for each of the three topics in the recommended three topic solution. 

![alt text](https://github.com/gzlupko/dnl_nlp/blob/main/reasons_stemmed_plot.png)


### Topic and Term Probabilities 
The below table shows the probabilities of each topic occuring in the corpus (overall collection of text data) as well as the the probability of each term occuring in the corpus. Note: this is based on a three-topic solution, which is recommended by the density statistic as well as a subjective content review of the groupings. 

![alt text](https://github.com/gzlupko/dnl_nlp/blob/main/beta_gamma_sample.png)



### N-gram Analyses 

N-gram analyses are used to understand which words are commonly used together in text (Finch et al., 2018). The below table shows bi-gram and tri-gram analyses of the decision data, indicating two and three word groupings that most commonly occur in the text data. 
 
 

![alt text](https://github.com/gzlupko/dnl_nlp/blob/main/sample_n-gram_analysis.png) 






The below table shows the most commonly occuring words that succeed target words from our topic model.

![alt text](https://github.com/gzlupko/dnl_nlp/blob/main/bi_gram_succeeding.png)




Bigram Network

![alt text](https://github.com/gzlupko/dnl_nlp/blob/main/bigram_network.png)

### Sentiment Analysis 

Below are word counts and associated sentiments for sample airline review Twitter data. 


![alt text](https://github.com/gzlupko/dnl_nlp/blob/main/sentiment_count.png)
