#' detect the encoding of texts
#' 
#' Detect the encoding of texts in a character, \link[quanteda]{corpus}, or 
#' \link{readtext} object and report on the most likely encoding.  Useful in
#' detecting the encoding of input texts, so that a source encoding can be 
#' (re)specified when inputting a set of texts using \code{\link{readtext}}, prior
#' to constructing a corpus.
#' 
#' Based on \link[stringi]{stri_enc_detect}, which is in turn based on the 
#' ICU libraries.  See the ICU User Guide, 
#' \url{http://userguide.icu-project.org/conversion/detection}.
#' @param x character vector, corpus, or readtext object whose texts' 
#'   encodings will be detected.
#' @param verbose if \code{FALSE}, do not print diagnostic report
#' @param ... additional arguments passed to \link[stringi]{stri_enc_detect}
#' @note This function has been \strong{temporarily} named \code{encoding} to avoid
#' namespace conflicts with \pkg{quanteda}, which until we remove it from that package
#' will retain the function \link[quanteda]{encoding}.
#' @examples
#' data(encodedTexts, package = "quanteda")
#' encoding(encodedTexts)
#' # show detected value for each text, versus known encoding
#' data.frame(labelled = names(encodedTexts), detected = encoding(encodedTexts)$all)
#'
#' \dontrun{
#' if ("quanteda" %in% installed.packages()[, "Package"]) {
#'     data(ie2010Corpus, package = "quanteda") 
#'     encoding(ie2010Corpus)
#' }}
#' 
#' \dontrun{# Russian text, Windows-1251
#' myreadtext <- readtext("http://www.kenbenoit.net/files/01_er_5.txt")
#' encoding(myreadtext)
#' }
#' @export
encoding <- function(x, verbose = TRUE, ...) {
    UseMethod("encoding")
}

#' @noRd
#' @export
#' @import data.table stringi
encoding.character <- function(x, verbose = TRUE, ...) {

    addedArgs <- names(list(...))
    if (length(addedArgs) && any(!(addedArgs %in% names(formals(stringi::stri_enc_detect)))))
        warning("Argument", ifelse(length(addedArgs)>1, "s ", " "), addedArgs, " not used.", sep = "", noBreaks. = TRUE)

    encoding <- confidence <- conf <- NULL
    n <- 1

    # assign names if none
    if (is.null(names(x))) 
        names(x) <- paste("text", 1:length(x), sep="")
    
    # detect encoding
    detectedEncodings <- stringi::stri_enc_detect(x, ...)
    dt <- data.table(text = rep(names(x), each=n),
                     encoding = unlist(lapply(detectedEncodings, function(x) x$Encoding[1:n])),
                     rank = rep(1:n, length(x)),
                     confidence = unlist(lapply(detectedEncodings, function(x) x$Confidence[1:n])))
    
    conftable <- dt[, mean(confidence), by = encoding]
    conftable <- conftable[!is.na(encoding)]
    setnames(conftable, "V1", "conf")
    conftable[, conf := conf/sum(conf)]
    conftable <- conftable[order(-conf)]
    
    # what are the top encodings
    topEncodingsTable <- dt[rank==1, mean(confidence), by = encoding]
    topEncodingsTable <- topEncodingsTable[!is.na(encoding)]
    setnames(topEncodingsTable, "V1", "conf")
    topEncodingsTable[, conf := conf/sum(conf)]
    topEncodingsTable <- topEncodingsTable[order(-conf)]
        
    if (verbose) 
        message("Probable encoding: ", topEncodingsTable[1, encoding], sep = "", appendLF = FALSE)
    if (nrow(topEncodingsTable) == 1 & topEncodingsTable[1, encoding] == "ISO-8859-1")
        if (verbose) 
            message("\n  (but note: detector often reports ISO-8859-1 when encoding is actually UTF-8.)",
                    appendLF = FALSE)
    if (nrow(topEncodingsTable) > 1) {
        if (verbose) 
            message("   (but ", "other encodings",
            # paste(topEncodingsTable[2:nrow(topEncodingsTable), encoding], collapse = ", "),
            " also detected)\n", sep = "", appendLF = FALSE)
        barsize <- 60
        proportions <- round(topEncodingsTable$conf * barsize)
        plotsymbols <- c("*", "-", ".", "~", letters[1:5])
        if (verbose) message("  Encoding proportions: ", appendLF = FALSE)
        if (verbose) message("[", rep(plotsymbols[1:nrow(topEncodingsTable)], 
                                      proportions[1:nrow(topEncodingsTable)]), "]", 
                             appendLF = FALSE)
        if (verbose) {
            message("\n  Samples of the first text as:")
            for (i in 1:nrow(topEncodingsTable)) {
                message(sprintf("%-21s", paste0("  [", plotsymbols[i], "] ",
                                                topEncodingsTable$encoding[i])),
                        stri_sub(suppressWarnings(stri_encode(x[1], topEncodingsTable$encoding[i])), length = 60))
            }
        }
    } else 
        if (verbose) message("")

    invisible(list(probably = topEncodingsTable[1, encoding], 
                   all = sapply(detectedEncodings, function(x) x$Encoding[1])))
}

#' @rdname encoding
#' @noRd
#' @export
encoding.readtext <- function(x, verbose = TRUE, ...) {
    if (verbose) print(x)
    encoding(as.character(x), ...)    
}


