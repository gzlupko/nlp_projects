# Note: This script takes several hours to run if all models are fitted.
# Note: Existing models may also be loaded in the script.
# You may want to skip to the existing models to shorten runtime.
library("stm")
library("topicmodels")
library("slam")

# If you do not want to run the code
# all the way through, you can load the results from:
# load("results.rda")

# Read in the data
data <- read.csv("poliblogs2008.csv")

############
# Preprocessing
############
set.seed(23456)
processed <- textProcessor(documents = data$documents, metadata = data)
out <- prepDocuments(documents = processed$documents, 
                     vocab = processed$vocab,
                     meta = processed$meta)
docs <- out$documents
vocab <- out$vocab
meta <- out$meta

plotRemoved(processed$documents, lower.thresh = seq(1, 200, by = 100))

###############
# Fitting the example model
###############

out <- prepDocuments(documents = processed$documents, 
                     vocab = processed$vocab,
                     meta = processed$meta, lower.thresh = 15)
shortdoc <- substr(out$meta$documents, 1, 200)
poliblogPrevFit <- stm(documents = out$documents, vocab = out$vocab,
                       K = 20, prevalence =~ rating + s(day), 
                       max.em.its = 75,
                       data = out$meta, init.type = "Spectral")

#################
# Model selection
#################

poliblogSelect <- selectModel(out$documents, out$vocab, K = 20,
                              prevalence =~ rating + s(day), max.em.its = 75,
                              data = out$meta, runs = 20, seed = 8458159)

pdf("stmVignette-009.pdf")
plotModels(poliblogSelect)
dev.off()

selectedmodel <- poliblogSelect$runout[[3]]

###############
# Searching Topic Numbers
###############
storage <- searchK(out$documents, out$vocab, K = c(7, 10),
                   prevalence =~ rating + s(day), data = meta)
t <- storage$out[[1]]
t <- storage$out[[2]]

##############################
# Describing the poliblogPrevFit model
#############################

labelTopics(poliblogPrevFit, c(6, 13, 18))

thoughts3 <- findThoughts(poliblogPrevFit, texts = shortdoc,
                          n = 2, topics = 6)$docs[[1]]
thoughts20 <- findThoughts(poliblogPrevFit, texts = shortdoc,
                           n = 2, topics = 18)$docs[[1]]

pdf("stmVignette-015.pdf")
par(mfrow = c(2, 1), mar = c(.5, .5, 1, .5))
plotQuote(thoughts3, width = 40, main = "Topic 6")
plotQuote(thoughts20, width = 40, main = "Topic 18")
dev.off()

meta$rating <- as.factor(meta$rating)
prep <- estimateEffect(1:20 ~ rating + s(day), poliblogPrevFit,
                       meta = out$meta, uncertainty = "Global")
summary(prep, topics = 1)

pdf("stmVignette-017.pdf")
plot(poliblogPrevFit, type = "summary", xlim = c(0, .3))
dev.off()

pdf("stmVignette-018.pdf")
plot(prep, covariate = "rating", topics = c(6, 13, 18),
     model = poliblogPrevFit, method = "difference",
     cov.value1 = "Liberal", cov.value2 = "Conservative",
     xlab = "More Conservative ... More Liberal",
     main = "Effect of Liberal vs. Conservative",
     xlim = c(-.1, .1), labeltype = "custom",
     custom.labels = c("Obama/McCain", "Sarah Palin", "Bush Presidency"))
dev.off()

pdf("stmVignette-019.pdf")
plot(prep, "day", method = "continuous", topics = 13,
     model = z, printlegend = FALSE, xaxt = "n", xlab = "Time (2008)")
monthseq <- seq(from = as.Date("2008-01-01"),
                to = as.Date("2008-12-01"), by = "month")
monthnames <- months(monthseq)
axis(1,
     at = as.numeric(monthseq) - min(as.numeric(monthseq)),
     labels = monthnames)
dev.off()

##############################
# Using the content covariate
#############################

poliblogContent <- stm(out$documents, out$vocab, K = 20,
                       prevalence =~ rating + s(day), content =~ rating,
                       max.em.its = 75, data = out$meta, init.type = "Spectral")
pdf("stmVignette-021.pdf")
plot(poliblogContent, type = "perspectives", topics = 10)
dev.off()

pdf("stmVignette-022.pdf")
plot(poliblogPrevFit, type = "perspectives", topics = c(16, 18))
dev.off()

##############################
# Using Interactions
#############################

poliblogInteraction <- stm(out$documents, out$vocab, K = 20,
                           prevalence =~ rating * day, max.em.its = 75,
                           data = out$meta, init.type = "Spectral")
prep <- estimateEffect(c(14) ~ rating * day, poliblogInteraction,
                       metadata = out$meta, uncertainty = "None")
pdf("stmVignette-024.pdf")
plot(prep, covariate = "day", model = poliblogInteraction,
     method = "continuous", xlab = "Days", moderator = "rating",
     moderator.value = "Liberal", linecol = "blue", ylim = c(0, .12),
     printlegend = FALSE)
plot(prep, covariate = "day", model = poliblogInteraction,
     method = "continuous", xlab = "Days", moderator = "rating",
     moderator.value = "Conservative", linecol = "red", add = TRUE,
     printlegend = FALSE)
legend(0, .06, c("Liberal", "Conservative"),
       lwd = 2, col = c("blue", "red"))
dev.off()
save(out, poliblogContent, poliblogInteraction, poliblogPrevFit,
     poliblogSelect, shortdoc, file = "results.rda")

############################
# Plotting clouds and correlations
############################

pdf("stmVignette-025.pdf")
cloud(poliblogPrevFit, topic = 13, scale = c(2, .25))
dev.off()
mod.out.corr <- topicCorr(poliblogPrevFit)
pdf("stmVignette-027.pdf")
plot(mod.out.corr)
dev.off()

############################
# Diagnostics
############################

pdf("stmVignette-028.pdf")
plot(poliblogPrevFit$convergence$bound, type = "l",
     ylab = "Approximate Objective",
     main = "Convergence")
dev.off()

# See v91i02-table1.R for replication of Table 1


