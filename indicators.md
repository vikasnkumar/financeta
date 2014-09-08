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

#### Simple Moving Average (SMA)

The simple moving average uses the simplest averaging formula over the period
window of prices. It simply adds all the prices in the period window divided by
the value of the period window.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Moving_average#Simple_moving_average)
- [FM Labs](http://www.fmlabs.com/reference/SimpleMA.htm)
- [tadoc.org](http://tadoc.org/indicator/SMA.htm)

#### Exponential Moving Average (EMA)

The exponential moving average is one of the most useful moving average
indicators being used today. It has a faster reaction time compared to the
SMA. The ratio or &alpha; is automatically calculated based on the period
window.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

For more details refer the resources at:

- [Wikipedia: EMA](https://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average)
- [Wikipedia: Exponential Smoothing](https://en.wikipedia.org/wiki/Exponential_smoothing)
- [FM Labs](http://www.fmlabs.com/reference/ExpMA.htm)
- [tadoc.org](http://tadoc.org/indicator/EMA.htm)

#### Double Exponential Moving Average (DEMA)

The DEMA has a lesser lag than the exponential moving average. It is a
combination of the EMA output and the EMA of the EMA output.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Exponential_smoothing#Double_exponential_smoothing)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=DEMA.htm)
- [tadoc.org](http://tadoc.org/indicator/DEMA.htm)

#### Triple Exponential Moving Average (TEMA)

The TEMA has a much lesser lag than the EMA, but has a more complex formula than
DEMA.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Exponential_smoothing#Triple_exponential_smoothing)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=TEMA.htm)
- [tadoc.org](http://tadoc.org/indicator/TEMA.htm)

#### Triple Exponential Moving Average (T3)

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

#### Weighted Moving Average (WMA)

The weighted moving average applies weights to data points at different
positions of the period window. The weights decrease in an arithmetic
progression.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Moving_average#Weighted_moving_average)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=WeightedMA.htm)
- [tadoc.org](http://tadoc.org/indicator/WMA.htm)

#### Triangular Moving Average (TMA)

The TMA is similar to the WMA where the weights are assigned in a triangular
pattern.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

For more details refer the resources at:

- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=TriangularMA.htm)
- [tadoc.org](http://tadoc.org/indicator/TRIMA.htm)

#### Moving Average with Variable Period (MAVP)

This is a type of _Adaptive_ moving average where the user provides a list of
periods to use to calculate the moving average of the series. In other words,
the period window cycles through the list and all the different moving average
series are merged into one.

This indicator takes four arguments: a list of integers (comma-separated)
denoting the different periods to use, a minimum period value, a maximum period
value and the type of moving average to use.

For example, the list of integers for the variable periods can be a [Fibonacci
sequence](https://en.wikipedia.org/wiki/Fibonacci#Fibonacci_sequence) of numbers
such as `2, 3, 5, 8, 13, 21, 34` and so on.

#### Kaufman Adaptive Moving Average (KAMA)

This is a type of _Adaptive_ moving average that adjusts its speed (or period
window) based on market volatility to make the moving average more
trend-efficient.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

For more details refer the resources at:

- [tadoc.org](http://tadoc.org/indicator/KAMA.htm)
- [etfhq.com](http://etfhq.com/blog/2011/11/07/adaptive-moving-average-ama-aka-kaufman-adaptive-moving-average-kama/)

#### MESA Adaptive Moving Average (MAMA)

This indicator relates the phase rate of change to the EMA &alpha; creating an
adaptive EMA indicator. For more details you will need to read the original
paper linked below.

This indicator uses two parameters: the upper limit and the lower limit, which
are both real numbers between 0.01 and 0.99. The recommended value for the upper
limit is 0.5 and the lower limit is 0.05.

For more details refer the resources at:

- [Original paper at archive.org](https://web.archive.org/web/20101010223736/http://www.mesasoftware.com/Papers/MAMA.pdf)
- [tadoc.org](http://tadoc.org/indicator/MAMA.htm)
- [Wealth Lab](http://www2.wealth-lab.com/wl5wiki/MAMA.ashx)

### Bollinger Bands (BBANDS)

Bollinger Bands is a popular volatility indicator used to indicate the rise and fall of
a price relative to previous trade prices. It consists of a type of periodic
moving average, an upper band a few standard deviations above the moving average
and a lower band a few standard deviations below the moving average.

There are four parameters for this indicator: the period window, the number of
standard deviations for the upper band, the number of standard deviations for
the lower band, and the type of moving average to use.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Bollinger_Bands)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=Bollinger.htm)
- [tadoc.org](http://tadoc.org/indicator/BBANDS.htm)

### Parabolic Stop And Reverse (SAR)

This is a popular indicator designed to find potential reversals in the market
price direction. This is a lagging indicator and may be used as a stop-loss
trigger. A parabola below the price is considered _bearish_ and above the price
is considered _bullish_. This indicator works on the high and low prices of the
security rather than the close price like the moving average indicators.

There are two parameters for this indicator: an acceleration factor which is a
positive real number and the maximum acceleration factor to use. The default
value of acceleration factor is 0.02 and the maximum acceleration factor is 0.2.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Parabolic_SAR)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=SAR.htm)
- [tadoc.org](http://tadoc.org/indicator/SAR.htm)

### Parabolic Stop And Reverse - Extended (SAREXT)

This is an extension to the above SAR indicator which gives the user the freedom
to use different acceleration factors for the long and short side trades.

There are many parameters that are configurable here:

- the start value which is a real number that denotes the start value and the
  sign of the number decides whether it is the long direction if positive, or the short
direction if negative, or auto-detect if 0. The default is 0.
- the percentage offset added or removed to the initial stop on the short or
  long reversal. The default is 0.
- the initial acceleration factor for the long direction. The default value is
  0.02.
- the acceleration factor for the long direction, with a default value of 0.02.
- the maximum acceleration factor for the long direction, with a default value
  of 0.2.
- the initial acceleration factor for the short direction. The default value is
  0.02.
- the acceleration factor for the short direction, with a default value of 0.02.
- the maximum acceleration factor for the short direction, with a default value
  of 0.02.

If all the default values are used, SAREXT is the same as SAR.

### Mid-point over period

This indicator calculates the average of the highest and lowest values of the
close prices in the period window selected.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

For more details refer the resource at:

- [tadoc.org](http://tadoc.org/indicator/MIDPOINT.htm)

### Mid-point Price over period

This indicator calculates the average of the highest high price and lowest low
price of the period window selected.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

For more details refer the resource at:

- [tadoc.org](http://tadoc.org/indicator/MIDPRICE.htm)

### Hilbert Transform - Instantaneous Trendline

This indicator has no parameters and works on the close price. It creates a
trend line that works on the current close price bar thus not have the same lag as the
various moving average indicators.

For more details refer the resources at:

- [tadoc.org](http://tadoc.org/indicator/HT_TRENDLINE.htm)
- [Wealth Lab](http://www2.wealth-lab.com/WL5Wiki/HTTrendLine.ashx)

## Volatility Indicators

### True Range

This indicator depicts the degree of price volatility. It uses the high, low and
close prices to create the indicator value.

There are no parameters for this indicator.

The plot of this indicator shows up as a sub-plot on the regular plot window.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/True_Range)
- [tadoc.org](http://tadoc.org/indicator/TRANGE.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=TR.htm)

### Average True Range (ATR)

This indicator depicts the degree of price volatility averaged over a rolling
period window. It uses the high, low and close prices to create the indicator value.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

The plot of this indicator shows up as a sub-plot on the regular plot window.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Average_true_range)
- [tadoc.org](http://tadoc.org/indicator/ATR.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=ATR.htm)

### Normalized Average True Range (NATR)

This is the normalized value of the ATR. Normalization makes the ATR function
more relevant in the scenarios where the price changes drastically over the long
term and the user is performing cross-market or cross-security ATR comparisons.
The ATR value is normalized using the close price and multiplied by 100.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

The plot of this indicator shows up as a sub-plot on the regular plot window.

For more details refer the resources at:

- [tadoc.org](http://tadoc.org/indicator/NATR.htm)
- [Article by creator John Forman](http://www.traders.com/Documentation/FEEDbk_docs/2006/05/Abstracts_new/Forman/formn.html)

## Momentum Indicators

### Momentum

The momentum indicator measures the acceleration or deceleration of prices over
a rolling period window. The indicator is applied to the close price, although
it can be applied to any data series.

There is only one parameter for this indicator: the period window which is a
valid integer between 1 and 100,000.

The plot of this indicator shows up as a sub-plot on the regular plot window.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Momentum_%28technical_analysis%29)
- [tadoc.org](http://tadoc.org/indicator/MOM.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=Momentum.htm)

### Moving Average Convergence-Divergence (MACD)

MACD is a very popular indicator that reveals changes in strength, direction,
momentum and duration of a trend in a stock's price. It generates three outputs:
the MACD output, the MACD signal and the MACD histogram (or the divergence
series) which is the difference between the MACD output and the MACD signal.

The plot of this indicator shows up as a sub-plot on the regular plot window.
The histogram shows up as a bar chart and the MACD output and signal are
overlaid on the histogram.

A combination of the crossing over of the MACD output and the signal over the
zero-line can be used to create buy/sell signals for trading.

The calculation for the MACD is the difference of two moving average series created
using two different period windows - fast and slow - where the fast period
window is shorter than the slow period window. The MACD signal is the moving
average of the MACD output itself over a period window generally referred to as
the smoothing period window.

There are three parameters for this indicator:

- fast period window which is a valid integer from 2 to 100,000 
- slow period window which is a valid integer from 2 to 100,000
- signal smoothing period window which is a valid integer from 1 to 100,000

The most common values of the period windows are 12 (fast), 26 (slow) and 9
(signal).

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/MACD)
- [tadoc.org](http://tadoc.org/indicator/MACD.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=MACD.htm)

#### MACD - with EMA

This is the default MACD indicator which uses the EMA to do the moving average.

#### MACD - Extended

This is the extended MACD indicator which allows the user to select a different
moving average type for each of the fast, slow and signal smoothing period
windows. If the user selects EMA for all, then this is the same as the default
MACD.

#### MACD Fixed 12/26 with EMA

This is a quicker implementation of the indicator where the user only selects
the signal smoothing period window. The slow and fast period windows are fixed
to 26 and 12, respectively. The moving average type is fixed to EMA.

### Money Flow Index (MFI)

### Relative Strength Index (RSI)

### Rate of Change

#### Rate of Change - Default

#### Rate of Change - Percentage

#### Rate of Change - Ratio

#### Rate of Change - Ratio scaled to 100

### Stochastic

#### Stochastic - Default

#### Stochastic - Fast

#### Stochastic - Relative Strength Index

### Average Directional Movement Index

### Average Directional Movement Index Rating

### Absolute Price Oscillator

### Aroon

### Aroon Oscillator

### Balance of Power (BOP)

### Commodity Channel Index

### Chande Momentum Oscillator

### Directional Movement Index

### Minus Directional Indicator

### Minus Directional Movement

### Plus Directional Indicator

### Plus Directional Movement

### Percentage Price Oscillator

### TRIX - 1-day Rate of Change of Triple Smooth EMA

### Ultimate Oscillator

### Williams' %R

**COMING SOON**

## Statistic Functions

### Beta

### Correlation (Pearson's Correlation Coefficient)

### Linear Regression

#### Linear Regression - Default

#### Linear Regression Angle

#### Linear Regression Intercept

#### Linear Regression Slope

### Standard Deviation

### Timeseries Forecast

### Variance

**COMING SOON**

## Volume Indicators

### Accumulation/Distribution (A/D)

#### Chaikin A/D Line

#### Chaikin A/D Oscillator

### On Balance Volume (OBV)

**COMING SOON**

## Price Transform

### Average Price

### Median Price

### Typical Price

### Weighted Close Price

**COMING SOON**

## Cycle Indicators (Hilbert Transform)

### Dominant Cycle Period

### Dominant Cycle Phase

### Phasor Components

### Sine Wave

### Trend vs Cycle Mode

## Candlestick Patterns

**COMING SOON**

Now that you are aware of the indicators that you may want to use, let's
learn how to write some rules to generate buy and sell signals in the [next
chapter](./rules.html).


[Table of Contents](./index.html) [Next](./rules.html)
