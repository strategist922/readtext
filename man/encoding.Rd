% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/encoding.R
\name{encoding}
\alias{encoding}
\title{detect the encoding of texts}
\usage{
encoding(x, verbose = TRUE, ...)
}
\arguments{
\item{x}{character vector, corpus, or readtext object whose texts' 
encodings will be detected.}

\item{verbose}{if \code{FALSE}, do not print diagnostic report}

\item{...}{additional arguments passed to \link[stringi]{stri_enc_detect}}
}
\description{
Detect the encoding of texts in a character, \link[quanteda]{corpus}, or 
\link{readtext} object and report on the most likely encoding.  Useful in
detecting the encoding of input texts, so that a source encoding can be 
(re)specified when inputting a set of texts using \code{\link{readtext}}, prior
to constructing a corpus.
}
\details{
Based on \link[stringi]{stri_enc_detect}, which is in turn based on the 
ICU libraries.  See the ICU User Guide, 
\url{http://userguide.icu-project.org/conversion/detection}.
}
\note{
This function has been \strong{temporarily} named \code{encoding} to avoid
namespace conflicts with \pkg{quanteda}, which until we remove it from that package
will retain the function \link[quanteda]{encoding}.
}
\examples{
data(encodedTexts, package = "quanteda")
encoding(encodedTexts)
# show detected value for each text, versus known encoding
data.frame(labelled = names(encodedTexts), detected = encoding(encodedTexts)$all)

\dontrun{
if ("quanteda" \%in\% installed.packages()[, "Package"]) {
    data(ie2010Corpus, package = "quanteda") 
    encoding(ie2010Corpus)
}}

\dontrun{# Russian text, Windows-1251
myreadtext <- readtext("http://www.kenbenoit.net/files/01_er_5.txt")
encoding(myreadtext)
}
}

