# CUDA Image Transformations

Supports the following image transformations:

* Swap green and blue colors
* Transform image to grayscale
* Blur image
* Generate Emboss


## Installation

Run:

    $ make


## Usage

    $ dist/cudatransform <swap|gray|blur|emboss> <infile> <outfile> (<area>)

* &lt;area&gt; is only used for blur mode.



### Examples

    $ dist/cudatransform swap examples/dice.png swapped_dice.png
    $ dist/cudatransform gray examples/Periodic_table_large.png gray_periodic_table.png


## License

The work is available as open source under the terms of the [GPL 3.0 License](https://opensource.org/licenses/GPL-3.0).
