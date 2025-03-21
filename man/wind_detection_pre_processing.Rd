% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wind_detection_functions.R
\name{wind_detection_pre_processing}
\alias{wind_detection_pre_processing}
\title{Pre-processing of files for Wind Detection program}
\usage{
wind_detection_pre_processing(
  wav_files,
  site_pattern,
  output_directory,
  write_to_file = FALSE,
  chunk_size = NULL
)
}
\arguments{
\item{wav_files}{Vector of path to wav files}

\item{site_pattern}{Pattern to extract sites from file names}

\item{output_directory}{Directory path to export files to}

\item{write_to_file}{Logical Should the function write files to output_directory}

\item{chunk_size}{Numeric If not NULL, sets number of files to include in each chunk}
}
\value{
List including filePath, filenames, and sites suitable for wind software.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}

This function takes a vector of wave file names and returns a list
of three vectors that can be provided to the wind detection software or
written to files that the software can read. Details of the usable fork of the
wind detection software can be found at
\url{https://github.com/dhope/WindNoiseDetection}
}
\examples{
 wind_files <-
 wind_detection_pre_processing(
 wav_files = example_clean$path,
   output_directory = td,
     site_pattern = create_pattern_site_id(
         p_digits = c(2, 3), sep = "_",
             s_digits = c(1, 2)
               ),
                 write_to_file = FALSE, chunk_size = NULL
                 )


}
