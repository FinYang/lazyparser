
# lazyparser: Command line R-flavored argument parser

<!-- badges: start -->
<!-- badges: end -->

The package `lazyparser` can be used in an R script to parse command
line arguments (when the script is called from the command line) as if
they are arguments to an R function.

Use `lazyparser` if you

1.  Need a simple way of parsing command line arguments by name with
    minimal dependency (`lazyparser` only depends on base R);
2.  Need to specify more complex argument than the atomic types.
3.  Do not care about providing command line usage/help message.

## Installation

You can install the development version of lazyparser like so:

``` r
remotes::install_github("FinYang/lazyparser")
```

## Example

Let us say you have an R script called “example.R” you want to run from
the command line with arguments

``` bash
Rscript example.R x=TRUE "y=seq_len(10)" "z = 'test'" 42L
```

The arguments can be specified using arbitrary R code. They can be very
long, but there cannot be any space in one argument, if you don’t wrap
them in quotation marks. Use quotation marks to wrap them when you want
to use a function or specify a string. The arguments are matched by name
then by location, just like in regular R functions.

Inside “example.R”, the following two lines can be used to parse these
arguments:

``` r
parser <- lazyparser::lazyparser(x, y = 10:1, z = "default", 
                                 a = 1L, b = "default value of b")
# The list of arguments goes into the function
# This can be specified like normal function arguments
# with optional default values
# The default value is used if no value is provided for the argument
args <- parser()
```

When this is being run from the command line, `parser()` will return a
named list with parsed arguments. The provided arguments on the command
line will be processed as regular R code so the type of the arguments
can be parsed correctly.

``` r
str(args)
```

    List of 5
     $ x: logi TRUE
     $ y: int [1:10] 1 2 3 4 5 6 7 8 9 10
     $ z: chr "test"
     $ a: int 42
     $ b: chr "default value of b"

If you are lazy as me, you probably don’t want to quote a string twice
every time the script is called, but `lazyparser` will treat it as an R
object if you don’t:

``` r
# example.R
parser <- lazyparser::lazyparser(x)
parser()
```

``` bash
# This will throw out an error
Rscript example.R A
```

    Error in eval(str2lang(.x)) : object 'A' not found
    Calls: parser ... eval -> .parser_internal -> lapply -> FUN -> eval -> eval
    Execution halted

``` bash
# This is the correct way of specify a string
Rscript example.R '"A"'
```

    $x
    [1] "A"

As a workaround, assign the strings you might want to specify to objects
with themselves as the name, then parse inside the the environment
containing the objects:

``` r
# example.R
parser <- lazyparser::lazyparser(x)
with(list(A = "A"), parser())
```

``` bash
# Now this can work
Rscript example.R A
```

    $x
    [1] "A"
