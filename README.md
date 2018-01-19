# CUDA Image Transformations

Supports the following image transformations:

* Swap green and blue colors
* Transform image to grayscale
* Blur image
* Generate Emboss


## Installation

Run:

    $ make all


## Usage

    $ dist/imgtrans-cuda <swap|gray|blur|emboss> <infile> <outfile> (<area>)
    $ dist/imgtrans-opencv <swap|gray> <infile> <outfile> (<area>)
    $ dist/imgtrans-plain <swap|gray> <infile> <outfile> (<area>)

* &lt;area&gt; is only used for blur mode.


### Examples

    $ dist/imgtrans-opencv swap examples/dice.png swapped_dice.png
    $ dist/imgtrans-cuda gray examples/Periodic_table_large.png gray_periodic_table.png


### Image Sources

* tricoloring.png: https://commons.wikimedia.org/wiki/File:Tricoloring.png
* dice.png: https://commons.wikimedia.org/wiki/File:PNG_transparency_demonstration_1.png
* periodic_table.png: https://commons.wikimedia.org/wiki/File:Periodic_table_large.png

## License

The work is available as open source under the terms of the [GPL 3.0 License](https://opensource.org/licenses/GPL-3.0).
