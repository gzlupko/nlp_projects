library(tm)
setwd("c:\\research\\maria nurse data\\corpus")
filenames<-list.files(getwd(),pattern="*")
files<-lapply(filenames,readLines)

docs<-Corpus(VectorSource(files))
writeLines(as.character(docs[[30]]))
docs<-tm_map(docs,content_transformer(tolower))

toSpace <- content_transformer(function(x, pattern) { return (gsub(pattern, " ", x))})
docs <- tm_map(docs, toSpace, "-")
docs <- tm_map(docs, toSpace, "’")
docs <- tm_map(docs, toSpace, "‘")
docs <- tm_map(docs, toSpace, "•")

#remove punctuation
docs <- tm_map(docs, removePunctuation)
#Strip digits
docs <- tm_map(docs, removeNumbers)
#remove stopwords
#docs <- tm_map(docs, removeWords, stopwords("english"))
docs <- tm_map(docs, removeWords, c("the", "and", "are", "a", "by", "for", "with", "our", "that", "there", "this", "them"))
#remove whitespace
docs <- tm_map(docs, stripWhitespace)
#Good practice to check every now and then
writeLines(as.character(docs[[30]]))
#Stem document
docs <- tm_map(docs,stemDocument)

#Create document-term matrix
dtm <- DocumentTermMatrix(docs)
#convert rownames to filenames
rownames(dtm) <- filenames
#collapse matrix by summing over columns
freq <- colSums(as.matrix(dtm))
#length should be total number of terms
length(freq)
#create sort order (descending)
ord <- order(freq,decreasing=TRUE)
#List all terms in decreasing order of freq and write to disk
freq[ord]
write.csv(freq[ord],"c:\\research\\maria nurse data\\word_freq.csv")

 
#Determine optimal number of topics using ldatuning#
library(ldatuning)

result.gibbs <- FindTopicsNumber(
  dtm,
  topics = seq(from = 2, to = 10, by = 1),
  metrics = c("Griffiths2004", "CaoJuan2009", "Arun2010", "Deveaud2014"),
  method = "GIBBS",
  
	control=list(seed = seed),
  mc.cores = 2L,
  verbose = TRUE
)

seed<-90178933469
result.gibbs <- FindTopicsNumber(
  dtm,
  topics = seq(from = 2, to = 10, by = 1),
  metrics = c("CaoJuan2009"),
  method = "GIBBS",
  
	control=list(seed = seed),
  mc.cores = 2L,
  verbose = TRUE
)

FindTopicsNumber_plot(result.gibbs)

#Fit appropriate topic model#
library(topicmodels)
#Set parameters for Gibbs sampling
burnin <- 4000
iter <- 2000
thin <- 500
seed <-list(2003,5,63,100001,765)
nstart <- 5
best <- TRUE

#Number of topics
k <- 3

#Run LDA using Gibbs sampling, and CTM using VEM#
ldaOut_q26 <-LDA(dtm,k, method="Gibbs", control=list(nstart=nstart, seed = seed, best=best, burnin = burnin, iter = iter, thin=thin))
ldaOut_q26.vem3 <-LDA(dtm,k, method="VEM")
ldaOut_q26.vem4 <-LDA(dtm,4, method="VEM")
ldaOut_q26.vem2 <-LDA(dtm,2, method="VEM")
ldaOut_q26.vem5 <-LDA(dtm,5, method="VEM")
ldaOut_q26.vem6 <-LDA(dtm,6, method="VEM")

perplexity(ldaOut_q26.vem6)

ctmOut3 <-CTM(dtm,k, control=list(nstart=nstart, seed = seed, best=best))

#Extract topics by document and terms by topic for LDA#
ldaOut_q26.topics <- as.matrix(topics(ldaOut_q26))
ldaOut_q26.terms <- as.matrix(terms(ldaOut_q26,10))

#Extract topics by document and terms by topic for CTM#
ctmOut3.topics <- as.matrix(topics(ctmOut3))
ctmOut3.terms <- as.matrix(terms(ctmOut3,6))

#probabilities associated with each topic assignment
topicProbabilities_lda_q26 <- as.data.frame(ldaOut_q26@gamma)
topicProbabilities_ctm3<-as.data.frame(ctmOut3@gamma)


write.csv(ldaOut_q26.topics,file="c:\\research\\maria nurse data\\lda_topic_q26b.csv")
write.csv(ctmOut3.topics,file="c:\\research\\maria nurse data\\ctm_topic3.csv")

write.csv(topicProbabilities_lda_q26,file="c:\\research\\maria nurse data\\lda_prob_q26.csv")
write.csv(topicProbabilities_ctm3,file="c:\\research\\maria nurse data\\ctm_prob3.csv")


#Calculate Hellinger Distance for topics#
library(clue)
dist_lda_q26<-distHellinger(posterior(ldaOut_q26)$terms)
matching_q26<-solve_LSAP(dist_lda_q26)
dist_lda_q26<-dist_lda3[,matching_q26]
d_q26<-mean(diag(dist_lda_q26))


#Using tidytext#
library(tidytext)

#Extract beta#
q26_topics <- tidy(ldaOut_q26, matrix = "beta")
q26_student<-q26_topics[ which(q26_topics$term=='student'),]
q26_contact<-q26_topics[ which(q26_topics$term=='contact'),]
q26_nurse<-q26_topics[ which(q26_topics$term=='nurs'),]
q26_parent<-q26_topics[ which(q26_topics$term=='parent'),]
q26_refer<-q26_topics[ which(q26_topics$term=='refer'),]
q26_teacher<-q26_topics[ which(q26_topics$term=='teacher'),]
q26_policy<-q26_topics[ which(q26_topics$term=='policies'),]
q26_not<-q26_topics[ which(q26_topics$term=='not'),]
q26_have<-q26_topics[ which(q26_topics$term=='have'),]
q26_dont<-q26_topics[ which(q26_topics$term=='dont'),]
q26_suicide<-q26_topics[ which(q26_topics$term=='suicid'),]
q26_injurious<-q26_topics[ which(q26_topics$term=='injuri'),]
q26_counselor<-q26_topics[ which(q26_topics$term=='counselor'),]
q26_psychologist<-q26_topics[ which(q26_topics$term=='psychologist'),]
q26_social<-q26_topics[ which(q26_topics$term=='social'),]
q26_self<-q26_topics[ which(q26_topics$term=='self'),]
q26_behavior<-q26_topics[ which(q26_topics$term=='behavior'),]
q26_train<-q26_topics[ which(q26_topics$term=='train'),]


library(ggplot2)
library(dplyr)

q26_top_terms <- q26_topics %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

q26_top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()

#Examine beta ratios#
library(tidyr)

beta_spread_1_2 <- q26_topics %>%
  mutate(topic = paste0("topic", topic)) %>%
  spread(topic, beta) %>%
  filter(topic1 > .001 | topic2 > .001) %>%
  mutate(log_ratio = log2(topic2 / topic1))

attach(beta_spread_1_2)
beta_spread_1_2_sort<-beta_spread_1_2[order(log_ratio),]
beta_spread_1_2_sort


beta_spread_1_3 <- q26_topics %>%
  mutate(topic = paste0("topic", topic)) %>%
  spread(topic, beta) %>%
  filter(topic1 > .01 | topic3 > .01) %>%
  mutate(log_ratio = log2(topic3 / topic1))

attach(beta_spread_1_3)
beta_spread_1_3_sort<-beta_spread_1_3[order(-abs(log_ratio)),]
beta_spread_1_3_sort


beta_spread_2_3 <- q26_topics %>%
  mutate(topic = paste0("topic", topic)) %>%
  spread(topic, beta) %>%
  filter(topic2 > .01 | topic3 > .01) %>%
  mutate(log_ratio = log2(topic3 / topic2))

attach(beta_spread_2_3)
beta_spread_2_3_sort<-beta_spread_2_3[order(-abs(log_ratio)),]
beta_spread_2_3_sort

q26_documents <- tidy(ldaOut_q26, matrix = "gamma")
q26_documents

tapply(q26_documents$gamma, q26_documents$topic, mean)