# ------------------------------------------------------------------
# This material is distributed under the GNU General Public License
# Version 2. You may review the terms of this license at
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Copyright (c) 2012-2013, Michel Lang, Helena Kotthaus,
# TU Dortmund University
#
# All rights reserved.
#
# Gradient based boosted regression using the mboost package with 
# default parameters
#
# USEAGE: Rscript [scriptfile] [problem-number] [number of replications]
# Output: unadjusted R^2
# ------------------------------------------------------------------
library(mboost)
type <- "regression"

args <- commandArgs(TRUE)
if (length(args)) {
  num <- as.integer(args[1])
  repls <- as.integer(args[2])
}

load(file.path("problems", sprintf("%s_%02i.RData", type, num)))

R2 <- numeric(repls)
for (repl in seq_len(repls)) {
  set.seed(repl)
  train <- sample(nrow(problem)) < floor(2/3 * nrow(problem))
  mod <- mboost(y ~ ., data = problem[train, ], control = boost_control(mstop = 1))
  mod[mstop(cvrisk(mod, papply = lapply, grid = 1:100))]
  y <- problem[!train, "y"]
  y.hat <- predict(mod, problem[!train, ])
  R2[repl] <- 1 - sum((y - y.hat)^2) / sum((y - mean(y))^2)
}
message(round(mean(R2), 4))
