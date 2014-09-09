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

#### Parabolic Stop And Reverse - Extended (SAREXT)

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
momentum and duration of a trend in a security's price. It generates three outputs:
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

This is the default MACD indicator which uses the
[EMA](#exponentialmovingaverageema) to do the moving average.

#### MACD - Extended

This is the extended MACD indicator which allows the user to select a different
moving average type for each of the fast, slow and signal smoothing period
windows. If the user selects [EMA](#exponentialmovingaverageema) for all, then this is the same as the default
MACD. The default moving average types are set to
[SMA](#simplemovingaveragesma).

#### MACD Fixed 12/26 with EMA

This is a quicker implementation of the indicator where the user only selects
the signal smoothing period window. The slow and fast period windows are fixed
to 26 and 12, respectively. The moving average type is fixed to
[EMA](#exponentialmovingaverageema).

### Money Flow Index (MFI)

MFI is an index with values between 0 and 100 used to show the value of a day's
trading over a rolling period window. It calculates a positive and negative
money flow based on the [typical price](#typicalpriceakapivotpoint) and volume
directions and gives a scaled ratio between 0 to 100.

It is used to determine the _enthusiasm_ of the market based on how much a
security has been traded.

This indicator has one parameter: the period window which is an integer between
2 and 100,000.

The plot of this indicator shows up as a sub-plot on the regular plot window.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Money_flow_index)
- [tadoc.org](http://tadoc.org/indicator/MFI.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=MoneyFlowIndex.htm)

### Relative Strength Index (RSI)

The RSI is a popular momentum indicator measuring the velocity and magnitude of
directional price movements over a rolling period window. It is generally used
in tandem with [MACD](#movingaverageconvergence-divergencemacd) and
[Stochastic](#stochastic) to create buy and sell signals.

This indicator has one parameter: the period window which is an integer between
2 and 100,000.

The plot of this indicator shows up as a sub-plot on the regular plot window.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Relative_strength_index)
- [tadoc.org](http://tadoc.org/indicator/RSI.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=RSI.htm)

### Rate of Change (ROC)

The ROC is the ratio of the change in the close price today with respect to the
close price a fixed number of days ago. This indicator is generally a fraction
depicting the trend in the prices over time. It is used in tandem with the
[Momentum](#momentum) indicator.

This indicator takes one parameter: a period window which is an integer value
between 1 and 100,000. The default period window is 10.

The plot of this indicator shows up as a sub-plot on the regular plot window.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Momentum_%28technical_analysis%29)
- [Investopedia](http://www.investopedia.com/articles/technical/092401.asp)
- [FM Labs (ROCP)](http://www.fmlabs.com/reference/default.htm?url=RateOfChange.htm)
- [tadoc.org (ROC)](http://tadoc.org/indicator/ROC.htm)
- [tadoc.org (ROCP)](http://tadoc.org/indicator/ROCP.htm)
- [tadoc.org (ROCR)](http://tadoc.org/indicator/ROCR.htm)
- [tadoc.org (ROCR100)](http://tadoc.org/indicator/ROCR100.htm)

#### Rate of Change - Default

The ratio between today's close price and the previous close price is subtracted by 1 and multiplied by 100.

#### Rate of Change - Percentage (ROCP)

The ratio between today's close price and the previous close price is subtracted by 1.

#### Rate of Change - Ratio

This is the ratio between today's close price and the previous close price.

#### Rate of Change - Ratio scaled to 100

This is the ratio between today's close price and the previous close price
multiplied by 100.

### Stochastic

The stochastic indicator refers to the point of a current price in relation to
the price range over time. The method tries to predict the turn in price change
by comparing the closing price to the price range.

There are two signals named `K` and `D` created by using the high, low and
close prices over a fast and slow period window for the `K` and the `D` signals.

Typical fast and slow period windows for `K` and `D` are 5 and 3, respectively.

The plot of this indicator shows up as a sub-plot on the regular plot window.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Stochastic_oscillator)
- [tadoc.org - STOCH](http://tadoc.org/indicator/STOCH.htm)
- [tadoc.org - STOCHF](http://tadoc.org/indicator/STOCHF.htm)
- [FM Labs - STOCH and STOCHF](http://www.fmlabs.com/reference/default.htm?url=StochasticOscillator.htm)
- [tadoc.org - STOCHRSI](http://tadoc.org/indicator/STOCHRSI.htm)
- [FM Labs - STOCHRSI](http://www.fmlabs.com/reference/default.htm?url=StochRSI.htm)

#### Stochastic - Slow (STOCH)

This returns the slow `K` and `D` signal streams by using the following
parameters that are configurable by the user:

- the period window for the fast `K` signal which is an integer between 1 and
  100,000 with a default value of 5
- the period window for the slow `K` signal which is an integer between 1 and
  100,000 with a default value of 3
- the moving average type for the slow `K` signal which by default is
  [SMA](#simplemovingaveragesma)
- the period window for the slow `D` signal which is an integer between 1 and
  100,000 with a default value of 3
- the moving average type for the slow `D` signal which by default is
  [SMA](#simplemovingaveragesma)

#### Stochastic - Fast (STOCHF)

This returns the fast `K` and `D` signal streams by using the following
parameters that are configurable by the user:

- the period window for the fast `K` signal which is an integer between 1 and
  100,000 with a default value of 5
- the period window for the fast `D` signal which is an integer between 1 and
  100,000 with a default value of 3
- the moving average type for the fast `D` signal which by default is
  [SMA](#simplemovingaveragesma)

#### Stochastic - Relative Strength Index (STOCHRSI)

This indicator is special in the sense that it creates the stochastic of the
[RSI](#relativestrengthindexrsi) indicator.

The configurable parameters are as follows:

- the period window for calculating the [RSI](#relativestrengthindexrsi) which is an integer between 2 and
  100,000
- the period window for the fast `K` signal which is an integer between 1 and
  100,000 with a default value of 5
- the period window for the fast `D` signal which is an integer between 1 and
  100,000 with a default value of 3
- the moving average type for the fast `D` signal which by default is
  [SMA](#simplemovingaveragesma)

### TRIX

Trix or TRIX is the slope of the [TEMA](#tripleexponentialmovingaveragetema)
which is calculated as the ratio of the difference between today's and
yesterday's TEMA values and today's TEMA value scaled by a factor of 100.

There is one parameter for this indicator: the period window for the moving
average which is an integer from 1 to 100,000.

The plot of this indicator shows up as a sub-plot on the regular plot window.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Trix_%28technical_analysis%29)
- [tadoc.org](http://tadoc.org/indicator/TRIX.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=TRIX.htm)

### Ultimate Oscillator

This oscillator is based on buying and selling _pressure_ created when the close
price of the day falls within the day's [true range](#truerange) value.

Three different period lengths are used to average the buying or selling
_pressures_ and in the ratio of 4:2:1 of the averages in the order of the
shortest to the longest period divided by 7 (4 + 2 + 1) and scaled by 100.

The parameters for this indicator are 3 values of the period windows, each being
an integer from 1 to 100,000. The default values are 7, 14 and 28.

The plot of this indicator shows up as a sub-plot on the regular plot window.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Ultimate_oscillator)
- [tadoc.org](http://tadoc.org/indicator/ULTOSC.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=UltimateOsc.htm)

### Williams' %R

This is an oscillator that shows the relation of the current close price to the
high and low prices of the previous rolling period window. Its purpose is to
notify whether a security is trading near the high or the low or somewhere in
between of its recent trading range.

The parameters for this indicator is a period window which is an integer from
2 to 100,000 with a default value of 14.

The plot of this indicator shows up as a sub-plot on the regular plot window.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Williams_%25R)
- [tadoc.org](http://tadoc.org/indicator/WILLR.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=WilliamsR.htm)

### Commodity Channel Index (CCI)

The CCI is used to detect the beginning and end of market trends. It uses the
high, low and close prices to calculate the [typical price](#typicalpriceakapivotpoint) and
the [SMA](#simplemovingaveragesma) of the typical price and retrieve a ratio
between the difference of these values and their mean deviations. A value
between -100 and 100 is the normal trading range, and any other values outside
this range indicate over-bought or over-sold conditions.

The parameters for this indicator is a period window which is an integer from
2 to 100,000 with a default value of 14.

The plot of this indicator shows up as a sub-plot on the regular plot window.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Commodity_channel_index)
- [tadoc.org](http://tadoc.org/indicator/CCI.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=CCI.htm)

### Average Directional Movement Index (ADX)

ADX is an indicator that denotes the strength of the trend in a security's
prices. It is a lagging indicator and depends on the period window being used.

ADX combines the [-DI](#minusdirectionalindicator-di) and [+DI](#plusdirectionalindicatordi)
indicator using an [EMA](#exponentialmovingaverageema).

There is one parameter for this indicator: the period window which is an integer
between 2 and 100,000 with a default value of 14.

The plot of this indicator shows up as a sub-plot on the regular plot window.

####  ADX

The ADX is 100 times the [EMA](#exponentialmovingaverageema) of the
absolute value of [DX](#directionalmovementindexdx).

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Average_directional_index)
- [tadoc.org](http://tadoc.org/indicator/ADX.htm)
- [Investopedia](http://www.investopedia.com/articles/technical/02/041002.asp)

#### Average Directional Movement Index Rating (ADXR)

This is the ratio of the current [ADX](#averagedirectionalmovementindexadx) with the
ADX value from the beginning of the previous rolling period window.

For more details refer the resources at:

- [tadoc.org](http://tadoc.org/indicator/ADXR.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=ADXR.htm)

#### Minus Directional Movement (-DM)

The -DM value is a series where the value is the difference between the previous
day's low price and the current low price if the difference is positive and greater than the
difference between the previous day's high price and the current high price, or
if not, then the value is 0.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Average_directional_index)
- [tadoc.org](http://tadoc.org/indicator/MINUS_DM.htm)
- [Investopedia](http://www.investopedia.com/articles/technical/02/050602.asp)

#### Plus Directional Movement (+DM)

The +DM value is a series where the value is the difference between the previous
day's high price and the current high price if the difference is positive and greater than the
difference between the previous day's low price and the current low price, or
if not, then the value is 0.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Average_directional_index)
- [tadoc.org](http://tadoc.org/indicator/PLUS_DM.htm)
- [Investopedia](http://www.investopedia.com/articles/technical/02/050602.asp)

#### Minus Directional Indicator (-DI)

The -DI value is 100 times the [EMA](#exponentialmovingaverageema) value of
[-DM](#minusdirectionalmovement-dm) divided by the [ATR](#averagetruerangeatr).

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Average_directional_index)
- [tadoc.org](http://tadoc.org/indicator/MINUS_DI.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=DI.htm)

#### Plus Directional Indicator (+DI)

The +DI value is 100 times the [EMA](#exponentialmovingaverageema) value of
[+DM](#plusdirectionalmovementdm) divided by the [ATR](#averagetruerangeatr).

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Average_directional_index)
- [tadoc.org](http://tadoc.org/indicator/PLUS_DI.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=DI.htm)

### Directional Movement Index (DX)

The DX is the ratio of the differences and sum of the [+DI](#plusdirectionalindicatordi) and
[-DI](#minusdirectionalindicator-di) values.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Average_directional_index)
- [tadoc.org](http://tadoc.org/indicator/DX.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=DX.htm)

### Absolute Price Oscillator (APO)

This indicator is similar to [MACD](#movingaverageconvergence-divergencemacd) in
that it is the difference of a fast and slow period moving average. A value
above 0 indicates a buy signal and a value below 0 indicates a sell signal.

This indicator takes three parameters: a fast rolling period window between 2
and 100,000 with a default value of 12, a slow period window between 2 and 100,000
with a default value of 26 and the type of moving average with a default value
of [SMA](#simplemovingaveragesma).

The plot of this indicator is overlaid on top of the price plot.

For more details refer the resources at:

- [tadoc.org](http://tadoc.org/indicator/APO.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=PriceOscillator.htm)

### Percentage Price Oscillator (PPO)

The PPO is like [APO](#absolutepriceoscillatorapo) where the generated values
are the ratio of the APO values to the fast moving average multiplied by 100.

This indicator takes three parameters: a fast rolling period window between 2
and 100,000 with a default value of 12, a slow period window between 2 and 100,000
with a default value of 26 and the type of moving average with a default value
of [SMA](#simplemovingaveragesma).

The plot of this indicator is overlaid on top of the price plot.

For more details refer the resources at:

- [tadoc.org](http://tadoc.org/indicator/PPO.htm)
- [FK Labs](http://www.fmlabs.com/reference/default.htm?url=PriceOscillatorPct.htm)

### Aroon

The Aroon indicator attempts to show when a new trend is beginning. The
indicator consists of two lines - _Up_ and _Down_ - that measure how long it has
been since the higest high and lowest low have occurred within a rolling period
window. This indicator works on the high and low prices of the security.

This indicator takes one parameter: the rolling period window which is an
integer between 2 and 100,000 with a default value of 14.

The plot of this indicator is a sub-plot in the plot window.

For more details refer to the resources at:

- [tadoc.org](http://tadoc.org/indicator/AROON.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=Aroon.htm)

#### Aroon Oscillator

The Aroon Oscillator is the difference between the [Aroon](#aroon) _Up_ and _Down_
values.

This indicator takes one parameter: the rolling period window which is an
integer between 2 and 100,000 with a default value of 14.

The plot of this indicator is a sub-plot in the plot window.

For more details refer to the resources at:

- [Wikipedia](http://tadoc.org/indicator/AROONOSC.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=AroonOscillator.htm)

### Chande Momentum Oscillator (CMO)

The CMO is a modified [RSI](#relativestrengthindexrsi) where the CMO divides the
net movement by the total movement.

This indicator takes one parameter: the rolling period window which is an
integer between 2 and 100,000 with a default value of 14.

The plot of this indicator is a sub-plot in the plot window.

For more details refer to the resources at:

- [Wikipedia](http://tadoc.org/indicator/CMO.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=CMO.htm)

### Balance of Power (BOP)

The BOP is a simple indicator which is just a ratio of the differences of the
close and open price and the high and low prices of the current day.

This indicator has no parameters.

The plot of this indicator is a sub-plot in the plot window.

For more details refer to the resources at:

- [tadoc.org](http://tadoc.org/indicator/BOP.htm)
- [tradeforextrading.com](http://www.tradeforextrading.com/index.php/balance-power-indicator)

## Statistic Functions

### Beta

The Beta indicator compares one security with another to give the user an
indication on how these securities move with respect to each other in the
market. The other security could be an index like Dow Jones Industrial Average
or S&P 500 or could be another security itself.

The most common usage of Beta is to understand the volatility of a security with
respect to a market index. A value less than 1 implies the security varies less
than the market and a value greater than 1 implies the security varies more than
the market and if the value is 1 the security follows the market.

Beta is calculated using a rolling period window which is an integer between 1
and 100,000 with a default value of 5.

The plot of this indicator has the second security overlaid on the first
security and a sub-plot showing the Beta line.

For more details refer the following resources:

- [Wikipedia](https://en.wikipedia.org/wiki/Beta_coefficient)
- [tadoc.org](http://tadoc.org/indicator/BETA.htm)

### Pearson's Correlation Coefficient

Pearson's correlation coefficient is an indicator that compares how two securities are related to each
other. It always has a value between -1.0 and 1.0. A negative value implies one
of the securities moves in an opposite direction to the other and a positive
value implies they move in sync. The closer these values are to the 1.0 line,
the more correlated these securities are to one another.

The correlation coefficient is calculated using a rolling period window which is an integer
between 1 and 100,000 with a default value of 5.

The plot of this indicator has the second security overlaid on the first
security and a sub-plot showing the Beta line.

For more details refer the following resources:

- [Wikipedia](https://en.wikipedia.org/wiki/Pearson_product-moment_correlation_coefficient)
- [tadoc.org](http://tadoc.org/indicator/CORREL.htm)

### Linear Regression

Linear regression attempts to fit a straight line between several data points in
such a way that the distance between each data point and the line is minimized.

For each point, a straight line over the specified previous bar period is
determined in terms of `y = b + m * x`.

The linear regression indicators take one parameter: the rolling period window
which is an integer between 2 and 100,000 with a default value of 14.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Linear_regression)
- [tadoc.org](http://tadoc.org/indicator/LINEARREG.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=RegressionLineMv.htm)

#### Linear Regression - Default

This returns the series that has the value `b + m * (period - 1)`.

The plot of this indicator is overlaid on the price plot.

#### Linear Regression Slope

This returns the series that has the value `m`.

The plot of this indicator is in a sub-plot on the plot window.

#### Linear Regression Angle

This returns the series that has the value `m` in degrees.

The plot of this indicator is in a sub-plot on the plot window.

#### Linear Regression Intercept

This returns the series that has the value `b`.

The plot of this indicator is in a sub-plot on the plot window.

#### Linear Regression Forecast

This returns the series that has the value `b + m * period`.

The plot of this indicator is overlaid on the price plot.

### Standard Deviation

Standard Deviation is a signal line created using a rolling period window of the
close price multiplied by the number of standard deviations requested by the
user.

This indicator has two parameters: the period window which is a value between 2
and 100,000 and the number of standard deviations requested. The default values
of the period window and number of standard deviations are 5 and 1.0,
respectively.

The plot of this indicator is in a sub-plot on the plot window.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Standard_deviation)
- [tadoc.org](http://tadoc.org/indicator/STDDEV.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=StdDevMv.htm)

### Variance

Variance is similar to the [standard deviation](#standarddeviation) indicator
where the variance is just the square of the standard deviation values.

This indicator has two parameters: the period window which is a value between 2
and 100,000 and the number of standard deviations requested. The default values
of the period window and number of standard deviations are 5 and 1.0,
respectively.

The plot of this indicator is in a sub-plot on the plot window.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Variance)
- [tadoc.org](http://tadoc.org/indicator/VAR.htm)

## Volume Indicators

### Accumulation/Distribution (A/D) Index

The A/D index is an indicator which takes the ratio of the changes in the high
and low prices of the day relative to the close price to the difference of the
high and low price of the day. This ratio is then scaled by the volume to create
the A/D value which is then plotted.

The plot of this indicator overlays on the volume plot. The user must select the
_OHLC & Volume_ or _Close & Volume_ plot options to turn on the volume plot.

#### A/D Line

This is the base indicator as described above. It has no parameters.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Accumulation/distribution_index)
- [tadoc.org](http://tadoc.org/indicator/AD.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=AccumDist.htm)

#### Chaikin A/D Oscillator

This indicator creates an oscillator by using a fast and slow period window
moving average of the A/D values.

This indicator has two parameters: the fast period and slow period windows which
are both integers between 2 and 100,000. The default values of the fast and slow
periods are 3 and 10, respectively.

For more details refer the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Accumulation/distribution_index#Chaikin_oscillator)
- [tadoc.org](http://tadoc.org/indicator/ADOSC.htm)

### On Balance Volume (OBV)

The OBV is a cumulative volume indicator that is used to confirm price moves in
the dominant direction. It uses the close price and the volume of the day for
its output.

This indicator has no parameters.

The plot of this indicator overlays on the volume plot. The user must select the
_OHLC & Volume_ or _Close & Volume_ plot options to turn on the volume plot.

For more details refer to the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/On-balance_volume)
- [tadoc.org](http://tadoc.org/indicator/OBV.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=OBV.htm)

## Price Transform

### Typical Price (aka Pivot Point)

The typical price is an average of the high, low and close price of the day.
This indicator may also be referred to as **pivot point**.

This indicator has no parameters.

For more details refer to the resources at:

- [Wikipedia](https://en.wikipedia.org/wiki/Typical_price)
- [tadoc.org](http://tadoc.org/indicator/TYPPRICE.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=TypicalPrices.htm)

### Average Price

This indicator is an average of the open, high, low and close prices of the day.

This indicator has no parameters.

For more details refer to the resources at:

- [tadoc.org](http://tadoc.org/indicator/AVGPRICE.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=AvgPrices.htm)

### Median Price

The median price is an average of the high and low price of the day.

This indicator has no parameters.

For more details refer to the resources at:

- [tadoc.org](http://tadoc.org/indicator/MEDPRICE.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=MedianPrices.htm)

### Weighted Close Price

This indicator is the average of the high, low and close price of the bar with
the close price multiplied by 2.

This indicator has no parameters.

For more details refer to the resources at:

- [tadoc.org](http://tadoc.org/indicator/WCLPRICE.htm)
- [FM Labs](http://www.fmlabs.com/reference/default.htm?url=WeightedCloses.htm)

### Mid-point Close over period

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

## Cycle Indicators (Hilbert Transform)

### Instantaneous Trendline

This indicator has no parameters and works on the close price. It creates a
trend line that works on the current close price bar thus not have the same lag as the
various moving average indicators.

For more details refer the resources at:

- [tadoc.org](http://tadoc.org/indicator/HT_TRENDLINE.htm)
- [Wealth Lab](http://www2.wealth-lab.com/WL5Wiki/HTTrendLine.ashx)

### Dominant Cycle Period

### Dominant Cycle Phase

### Phasor Components

### Sine Wave

### Trend vs Cycle Mode

**COMING SOON**

## Candlestick Patterns

**COMING SOON**

Now that you are aware of the indicators that you may want to use, let's
learn how to write some rules to generate buy and sell signals in the [next
chapter](./rules.html).


[Table of Contents](./index.html) [Next](./rules.html)