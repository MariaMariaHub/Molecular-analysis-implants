library(tidyverse)
library(ggplot2)

implants_qpcr <- read_csv("Data/implants 2019.csv", na = "null")
implants_qpcr

## Checking data
## Barplots to see counts on diagnosis vs implant brand and diagnosis vs implant surface
ggplot(implants_qpcr, aes(x = implant_surface)) + geom_bar(aes(fill = diagnosis), position = "dodge") + 
  labs(x = "Implant diagnosis", y = "Count") +
  facet_grid(~diagnosis)   

#########################################################################################################

## Checking outliers for total number of bacteria
boxplot(implants_qpcr$total_bacteria_per_mg_tissue)$out

## if don't want to see plot again
boxplot(implants_qpcr$total_bacteria_per_mg_tissue, plot=FALSE)$out

## assign the outlier values into a vector
outliers_total_bacteria <- boxplot(implants_qpcr$total_bacteria_per_mg_tissue, plot=FALSE)$out

print(outliers_total_bacteria)

## find out which rows contain outliers
implants_qpcr[which(implants_qpcr$total_bacteria_per_mg_tissue %in% outliers_total_bacteria),]

## remove rows containing outliers
implants_qpcr <- implants_qpcr[-which(implants_qpcr$total_bacteria_per_mg_tissue %in% outliers_total_bacteria),]

## check with boxplot
boxplot(implants_qpcr$total_bacteria_per_mg_tissue)

#########################################################################################################

## looking at data now
qplot(data = implants_qpcr, x = total_bacteria_per_mg_tissue) + ylab("total bacteria/mg tissue")

ggplot(data = implants_qpcr, aes(x = diagnosis, y = total_bacteria_per_mg_tissue)) +    
  geom_jitter(alpha = 0.5, width = 0.2, aes(color = implant_surface), height = 0.2) +       # added height so doesnt obscure data because of jitters you've added
  geom_boxplot(alpha = 0)
 
ggplot(data = implants_qpcr, aes(x = diagnosis, y = total_bacteria_per_mg_tissue)) +    
  geom_jitter(alpha = 0.5, width = 0.2, aes(color = implant_brand), height = 0.2) +         # added height so doesnt obscure data because of jitters you've added
  geom_boxplot(alpha = 0)

ggplot(data = implants_qpcr, aes(x = diagnosis, y = total_bacteria_per_mg_tissue)) +    
  geom_jitter(alpha = 0.5, width = 0.2, aes(color = ruptured), height = 0.2) +              # added height so doesnt obscure data because of jitters you've added
  geom_boxplot(alpha = 0)

#########################################################################################################

## Checking normality
library("dplyr")
library("ggpubr")

my_data <- implants_qpcr

## visualise by density plot if data normal
ggdensity(my_data$total_bacteria_per_mg_tissue, 
          main = "Density plot of total bacteria/mg tissue",
          xlab = "total bacteria/mg tissue")


ggqqplot(my_data$total_bacteria_per_mg_tissue)


## normality test
shapiro.test(my_data$total_bacteria_per_mg_tissue)

## Shapiro-Wilk normality test
## data:  my_data$sixteens_copy_number
## W = 0.80551, p-value = 1.104e-13       # Data is not normal since p < 0.05

## If the p-value > 0.05 implying that the distribution of the data are not significantly 
## different from normal distribution. In other words, we can assume the normality.

#########################################################################################################

## FOR DIAGNOSIS
## Default method = "kruskal.test" for multiple groups and since our data is not normal, can use this
ggboxplot(my_data, x = "diagnosis", y = "total_bacteria_per_mg_tissue",
          color = "diagnosis", palette = "jco")+
  stat_compare_means()


## Multiple pairwise tests against all (base-mean)
ggboxplot(my_data, x = "diagnosis", y = "total_bacteria_per_mg_tissue", color = "diagnosis", 
          add = "jitter", legend = "none") +
  rotate_x_text(angle = 45)+
  stat_compare_means(method = "kruskal.test", label.y = 4500000)+   
  stat_compare_means(label = "p.signif", method = "wilcox.test",
                     ref.group = ".all.")      # Pairwise comparison against all


ggboxplot(my_data, x = "diagnosis", y = "total_bacteria_per_mg_tissue", color = "diagnosis", 
          add = "jitter", legend = "none") +
  rotate_x_text(angle = 45)+
  stat_compare_means(method = "kruskal.test", label.y = 4500000)+       
  stat_compare_means(label = "p.signif", method = "wilcox.test",
                     ref.group = ".all.", hide.ns = TRUE)  


## Multiple grouping variables
compare_means(total_bacteria_per_mg_tissue ~ implant_surface, data = my_data, 
              group.by = "diagnosis")

# Box plot facetted by "diagnosis" with implant surface
p <- ggboxplot(my_data, x = "implant_surface", y = "total_bacteria_per_mg_tissue",
               color = "implant_surface", palette = "jco",
               add = "jitter",
               facet.by = "diagnosis", short.panel.labs = FALSE)
# Use only p.format as label. Remove method name.
p + stat_compare_means(label = "p.format", label.x = 1.5)

# Or use significance symbol as label
p + stat_compare_means(label =  "p.signif", label.x = 1.5)


## Multiple grouping variables
compare_means(total_bacteria_per_mg_tissue ~ ruptured, data = my_data, 
              group.by = "diagnosis")
# Box plot facetted by "diagnosis" with ruptured
p <- ggboxplot(my_data, x = "ruptured", y = "total_bacteria_per_mg_tissue",
               color = "ruptured", palette = "jco",
               add = "jitter",
               facet.by = "diagnosis", short.panel.labs = FALSE)
# Use only p.format as label. Remove method name.
p + stat_compare_means(label = "p.format", label.x = 1.5)

# Or use significance symbol as label
p + stat_compare_means(label =  "p.signif", label.x = 1.5)


## Multiple grouping variables
compare_means(total_bacteria_per_mg_tissue ~ surface, data = my_data, 
              group.by = "diagnosis")                                # surface is bottom, top, whole not paired test

# Box plot facetted by "diagnosis" with implant surface
p <- ggboxplot(my_data, x = "surface", y = "total_bacteria_per_mg_tissue",
               color = "surface", palette = "jco",
               add = "jitter",
               facet.by = "diagnosis", short.panel.labs = FALSE)
# Use only p.format as label. Remove method name.
p + stat_compare_means(label = "p.format", label.x = 2)

# Or use significance symbol as label
p + stat_compare_means(label =  "p.signif", label.x = 2)


#########################################################################################################

## FOR IMPLANT BRAND
## Default method = "kruskal.test" for multiple groups and since our data is not normal, can use this
ggboxplot(my_data, x = "implant_brand", y = "total_bacteria_per_mg_tissue",
          color = "implant_brand", palette = "jco")+
  stat_compare_means()


## Multiple pairwise tests against all (base-mean)
ggboxplot(my_data, x = "implant_brand", y = "total_bacteria_per_mg_tissue", color = "implant_brand", 
          add = "jitter", legend = "none") +
  rotate_x_text(angle = 45)+
  stat_compare_means(method = "kruskal.test", label.y = 4500000)+   
  stat_compare_means(label = "p.signif", method = "wilcox.test",
                     ref.group = ".all.")      # Pairwise comparison against all


ggboxplot(my_data, x = "implant_brand", y = "total_bacteria_per_mg_tissue", color = "implant_brand", 
          add = "jitter", legend = "none") +
  rotate_x_text(angle = 45)+
  stat_compare_means(method = "kruskal.test", label.y = 4500000)+       
  stat_compare_means(label = "p.signif", method = "wilcox.test",
                     ref.group = ".all.", hide.ns = TRUE)  


## Multiple grouping variables
compare_means(total_bacteria_per_mg_tissue ~ implant_surface, data = my_data, 
              group.by = "implant_brand")

# Box plot facetted by "diagnosis" with implant surface
p <- ggboxplot(my_data, x = "implant_surface", y = "total_bacteria_per_mg_tissue",
               color = "implant_surface", palette = "jco",
               add = "jitter",
               facet.by = "implant_brand", short.panel.labs = FALSE)
# Use only p.format as label. Remove method name.
p + stat_compare_means(label = "p.format", label.x = 1.5)

# Or use significance symbol as label
p + stat_compare_means(label =  "p.signif", label.x = 1.5)


## Multiple grouping variables
compare_means(total_bacteria_per_mg_tissue ~ ruptured, data = my_data, 
              group.by = "implant_brand")
# Box plot facetted by "diagnosis" with ruptured
p <- ggboxplot(my_data, x = "ruptured", y = "total_bacteria_per_mg_tissue",
               color = "ruptured", palette = "jco",
               add = "jitter",
               facet.by = "implant_brand", short.panel.labs = FALSE)
# Use only p.format as label. Remove method name.
p + stat_compare_means(label = "p.format", label.x = 1.5)

# Or use significance symbol as label
p + stat_compare_means(label =  "p.signif", label.x = 1.5)


## Multiple grouping variables
compare_means(total_bacteria_per_mg_tissue ~ surface, data = my_data, 
              group.by = "implant_brand")                                # surface is bottom, top, whole not paired test

# Box plot facetted by "diagnosis" with implant surface
p <- ggboxplot(my_data, x = "surface", y = "total_bacteria_per_mg_tissue",
               color = "surface", palette = "jco",
               add = "jitter",
               facet.by = "implant_brand", short.panel.labs = FALSE)
# Use only p.format as label. Remove method name.
p + stat_compare_means(label = "p.format", label.x = 2)

# Or use significance symbol as label
p + stat_compare_means(label =  "p.signif", label.x = 2)

#########################################################################################################







