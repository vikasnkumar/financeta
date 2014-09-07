# Indicators

_App::financeta_ supports a variety of indicators, about 132 of them. Here we
try to explain each one of them and for those that have better references
elsewhere we link to detailed explanations to those sites. We felt that there
was no reason to copy some other site's text when we could just link to their
efforts.

Each indicator's parameters are listed if necessary and explanations are given
as required for understanding how to use the indicator.

## Overlap Studies

These group of indicators work with the Close price of the security being used
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
- Wikipedia: <https://en.wikipedia.org/wiki/Moving_average>
- Metastock: <http://www.metastock.com/Customer/Resources/TAAZ/Default.aspx?p=74>

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
- Wikipedia: <https://en.wikipedia.org/wiki/Moving_average#Simple_moving_average>
- FM Labs: <http://www.fmlabs.com/reference/SimpleMA.htm>

### Exponential Moving Average (EMA)

The exponential moving average is one of the most useful moving average
indicators being used today. It has a faster reaction time compared to the
SMA.

There is only one parameter for this indicator: the period window which is a
valid integer between 2 and 100,000.

For more details refer the resources at:
- Wikipedia: <https://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average>
- FM Labs: <http://www.fmlabs.com/reference/ExpMA.htm>

### Double Exponential Moving Average (DEMA)

### Triple Exponential Moving Average (TEMA)

### Triple Exponential Moving Average (T3)

### Triangular Moving Average (TMA)

### Weighted Moving Average (WMA)

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
