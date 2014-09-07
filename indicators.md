# Indicators

_App::financeta_ supports a variety of indicators, about 132 of them. Here we
try to explain each one of them and for those that have better references
elsewhere we link to detailed explanations to those sites. We felt that there
was no reason to copy some other site's text when we could just link to their
efforts.

Each indicator's parameters are listed if necessary and explanations are given
as required for understanding how to use the indicator.

## Overlap Studies

These group of <u>trend following</u> indicators work with the Close price of the security being used
as the input. They overlap the actual security price chart and hence the name.

### Moving Average (MA)

Moving average is the easiest and simplest smoothing indicator used by technical
analysts and algorithmic traders. Fundamentally, they are implemented as running
an averaging formula over a rolling window of prices.

Analysts use a combination of various moving average lines to create simple
trading rules for securities. The moving average along with a few other
indicators can be applied to any kind of security such as stocks, futures or
options to smooth the volatility over fixed periods and get an idea of how to
see trends in a price.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Moving_average)
- [Metastock](http://www.metastock.com/Customer/Resources/TAAZ/Default.aspx?p=74)

There are many popular methods of calculating the moving average which are
explained in the following sections.

This indicator is actually a collective indicator in the sense that selecting
this indicator allows the user to choose which type of moving average they would
like to pick. The indicator takes two parameters: the period window which is a
valid integer between 2 and 100,000 and the type of moving average. Each of
these types of moving averages are explained below.

### Simple Moving Average (SMA)

The simple moving average uses the simplest averaging formula over the period
window of prices. It simply adds all the prices in the period window divided by
the value of the period window.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Moving_average#Simple_moving_average)
- [FM Labs](http://www.fmlabs.com/reference/SimpleMA.htm)
- [tadoc.org](http://tadoc.org/indicator/SMA.htm)

### Exponential Moving Average (EMA)

The exponential moving average is one of the most useful moving average
indicators being used today. It has a faster reaction time compared to the
SMA.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

For more details refer the resources at:

- [Wikipedia: EMA](https://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average)
- [Wikipedia: Exponential Smoothing](https://en.wikipedia.org/wiki/Exponential_smoothing)
- [FM Labs](http://www.fmlabs.com/reference/ExpMA.htm)
- [tadoc.org](http://tadoc.org/indicator/EMA.htm)

### Double Exponential Moving Average (DEMA)

The DEMA has a lesser lag than the exponential moving average. It is a
combination of the EMA output and the EMA of the EMA output.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Exponential_smoothing#Double_exponential_smoothing)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=DEMA.htm)
- [tadoc.org](http://tadoc.org/indicator/DEMA.htm)

### Triple Exponential Moving Average (TEMA)

The TEMA has a much lesser lag than the EMA, but has a more complex formula than
DEMA.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Exponential_smoothing#Triple_exponential_smoothing)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=TEMA.htm)
- [tadoc.org](http://tadoc.org/indicator/TEMA.htm)

### Triple Exponential Moving Average (T3)

The T3 is similar to the DEMA but adds a volume factor (`vfactor`) based
scaling to the DEMA calculation. The `vfactor` is a real number between 0.0 and
1.0. A typical value for `vfactor` is 0.7. If the `vfactor` is 0.0 then T3 is
the same as EMA and if it is 1.0 then T3 is the same as DEMA.

There are two parameters for this indicator: the volume factor which is a real number
between 0.0 and 1.0, and the period window which is a valid integer between 2 and 100,000.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Exponential_smoothing#Triple_exponential_smoothing)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=T3.htm)
- [tadoc.org](http://tadoc.org/indicator/T3.htm)

### Weighted Moving Average (WMA)

The weighted moving average applies weights to data points at different
positions of the period window. The weights decrease in an arithmetic
progression.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Moving_average#Weighted_moving_average)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=WeightedMA.htm)
- [tadoc.org](http://tadoc.org/indicator/WMA.htm)

### Triangular Moving Average (TMA)

The TMA is similar to the WMA where the weights are assigned in a triangular
pattern.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

For more details refer the resources at:

- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=TriangularMA.htm)
- [tadoc.org](http://tadoc.org/indicator/TRIMA.htm)

### Kaufman Adaptive Moving Average (KAMA)

### MESA Adaptive Moving Average (MAMA)

### Moving Average with Variable Period (MAVP)

### Bollinger Bands

### Parabolic Stop And Reverse (SAR)

### Parabolic Stop And Reverse (SAR) - Extended

### Mid-point over period

### Mid-point Price over period

### Hilbert Transform - Instantaneous Trendline

## Momentum Indicators

## Statistic Functions

## Volatility Indicators

## Volume Indicators

## Price Transform

## Cycle Indicators

## Candlestick Patterns

**COMING SOON**
