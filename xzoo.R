## zoo extras

## take first recorded value
baseline <- function(id, time, x) {
  s <- splitdata(id, time, x)
  u <- unlist(lapply(s, function(y) y[1, 1]), use.names = FALSE)
  b <- u <- u[attributes(s)$uid]
  b[attributes(s)$order] <- u
  ## restore factor class
  if (is.factor(x))
    factor(levels(x)[b])
  else
    b
}

## center or (if sd = TRUE) standardize time-specific values
center <- function(id, time, x, sd = FALSE, na.rm = TRUE) {
  z <- zoosplit(splitdata(id, time, x))
  m <- apply(do.call(rbind, lapply(z, coredata)), 2, mean, na.rm = na.rm)
  c <- lapply(z, function(y) y - m)
  if (sd) {
    s <- apply(do.call(rbind, lapply(z, coredata)), 2, sd, na.rm = na.rm)
    c <- lapply(c, function(y) y / s)
  }
  attributes(c) <- attributes(z)
  mode(c) <- mode(z)
  unzoosplit(c)
}

## current value minus lagged value, shifted back k time points
change <- function(id, time, x, k = 1) {
  z <- zoosplit(splitdata(id, time, x))
  d <- lapply(z, function(y) if (length(y) > 1) diff(y, lag = k, na.pad = TRUE)
                             else NA)
  attributes(d) <- attributes(z)
  mode(d) <- mode(z)
  d <- unzoosplit(d)
  d
}

## return lagged value, shifted by k time points
delay <- function(id, time, x, k = 1) {
  s <- splitdata(id, time, x)
  b <- unlist(lapply(s, function(y) y[1, 1]), use.names = FALSE)
  b <- b[attributes(s)$uid][attributes(s)$order]
  z <- zoosplit(s)
  l <- lapply(z, function(y) if (length(y) > 1) lag(y, k = -k, na.pad = TRUE)
                             else NA)
  attributes(l) <- attributes(z)
  mode(l) <- mode(z)
  l <- unzoosplit(l)
  l
}

## single imputation of missing values using zoo's na.* functions
impute <- function(id, time, x, fun = na.locf, na.rm = FALSE, ...) {
  xmin <- min(x, na.rm = TRUE)
  xmax <- max(x, na.rm = TRUE)
  z <- zoosplit(splitdata(id, time, x))
  n <- lapply(z, function(y) if (all(is.na(y))) y
                             else fun(y, na.rm = na.rm, ...))
  n <- unzoosplit(n)
  n[n < xmin] <- xmin
  n[n > xmax] <- xmax
  attributes(n) <- attributes(x)
  mode(n) <- mode(x)
  n
}

## rolling summary with given right-aligned window width
roll <- function(id, time, x, width = NULL, FUN, ...) {
  z <- zoosplit(splitdata(id, time, x))
  if (is.null(width))
    width <- do.call("max", lapply(z, length))
  r <- lapply(z, function(y) if (all(is.na(y))) NA
                             else rollapplyr(y, width = width, FUN = FUN,
                                             partial = TRUE, ...))
  attributes(r) <- attributes(z)
  mode(r) <- mode(z)
  unzoosplit(r)
}

## split data by id
splitdata <- function(id, time, x) {
  s <- lapply(split(data.frame(x, order.by = time), id),
              function(y) y[order(y$order.by), , drop = FALSE])
  attributes(s)$order <-
    as.numeric(unlist(lapply(s, rownames), use.names = FALSE))
  nid <- unlist(lapply(s, nrow))
  attributes(s)$id <- as.numeric(rep(names(s), times = nid))
  attributes(s)$uid <- rep(1:length(nid), times = nid)
  s
}

## apply zoo to output from splitdata
zoosplit <- function(s) {
  z <- lapply(s, function(y) do.call(zoo, y))
  attributes(z) <- attributes(s)
  mode(z) <- mode(s)
  z
}

## unsplit output from zoosplit
unzoosplit <- function(z, indexed = FALSE) {
  x <- u <- unlist(z, use.names = FALSE)
  if (indexed) {
    x <- data.frame(id = attributes(z)$id,
                    time = unlist(lapply(z, time), use.names = FALSE),
                    x = x)
    x[attributes(z)$order, ] <- x
  }
  else x[attributes(z)$order] <- u
  class(x) <- attributes(z)$oclass
  levels(x) <- levels(z)
  x
}
