# Calibrating color on a Toshiba 19a21 CRT TV

## 1742486505

I've been interested in picking up a CRT for a few years now, so when found I one on the side of the road during a walk the other day it seemed like a sign. Now I'm the proud owner of a Toshiba 19A21, a low-end TV from 2001. I also now know that I can carry a medium-sized CRT about three blocks before my arms turn to jelly.

The picture was decent, but it could be better - plus I just wanted to learn more about how to calibrate it. I looked up some guides and dove in, and after an hour or so of trial and error this is what I've learned.

These are the settings I have to work with, from the on-screen display. I haven't adjusted any potentiometers (yet). Note that my descriptions here are more how they're used than what they actually *do*.

- R/G/B Bias - black / dark color balance
- R/B Drv - bright color balance
- Color - saturation
- Tint - hue
- Contrast - highlight brightness
- Brightness - shadow brightness / cutoff

First things first I set each of those to their midpoint values, besides Color, which has a minimum of 32 and looks horrendous if it's much higher than that.

Next is adjusting Brightness. With an <a href="https://en.wikipedia.org/wiki/SMPTE_color_bars">SMPTE test pattern</a> we need to look at the three skinny vertical gray bars near the bottom right. Brightness should be adjusted until, counterintuitively, the left two should both look the same, pure black, while the right one should just barely be visible.

Then we adjust Contrast. This is more subjective, I think; 'officially' you want it as high as possible before the picture starts blooming, where bright colors bleed into dark areas. But that point is uncomfortably bright for me, especially for the dimly lit room where I have the TV. Plus, higher contrast ages the CRT faster. So I opted for a pretty low setting but really just use whatever looks nice to your eye.

R/G/B Bias is pretty simple; just adjust until blacks and dark grays look neutral, not too warm or cool.

It's worth mentioning that, while I don't have a colorimeter, I do have access to <a href="https://www.notebookcheck.net/">notebookcheck.net</a>, who kindly provides ICC color calibration files for all the laptops they review; meaning you can get proper color calibration for a laptop you own, which makes for a decent reference going forward.

And that takes us to R/B Drive. This is the main color adjustment, and the trickiest part to get right. Using an RGB gradient pattern like <a href="http://www.lagom.nl/lcd-test/all_noprofile.php#colorbands.png">this</a>, each should be more or less the same intensity as the others. "Color" should be adjusted so you can clearly differentiate between each of the most saturated bands. White should look, well, white. Since there's no green adjustment I just treated it as a fixed value and adjusted the other channels relative to it.

As for Tint, which is basically hue, if you need to make any adjustments from the default / center value they'll probably be pretty minor. It's easiest to see with a SMTPE test pattern; the yellow should look pure yellow, like a lemon or banana, no green or orange to it. The magenta should look pure magenta too, without any red or purple but right smack in the middle.

That's it. Probably my favorite bit of trivia from all this is how NTSC is known as "Never Twice the Same Color". After playing around with the settings for an hour or so I'm pretty happy where it ended up - yellows look a bit weak, and reds a bit strong, but I think I'm at the point where further adjustments are more likely to drive me crazy than improve the picture. Even though it looks way better than when I took it home and plugged it in for the first time, it's funny how the imperfections start to stand out more once you dive into the finer details of things like this.

CRT displays are imperfect by nature, though; they use and abuse the laws of physics well past the point of being sufficiently advanced enough to be indistinguishable from magic, and they're inextricably tied to the physical world in a way LED displays just aren't. You see the grill, hear the beam, watch the picture fade in as it literally warms up. You learn about how it works just by using it. Not to say modern displays are entirely devoid of that quality, and of course their accuracy and convenience makes them objectively superior for the purpose of displaying pictures. But there is something lost between analog and digital; as silly as it looks it brings me great joy to see my CRT TV sitting next to an LED TV, both old and new offering their strengths.

Sources / further reading:

- <a href="https://crtdatabase.com/faq/crt-color-adjustment">https://crtdatabase.com/faq/crt-color-adjustment</a>
- <a href="https://wiki.arcadeotaku.com/w/How_to_Correctly_Set_Up_Monitor_Colours_and_Brightness">https://wiki.arcadeotaku.com/w/How\_to\_Correctly\_Set\_Up\_Monitor\_Colours\_and\_Brightness</a>
- <a href="https://crtdatabase.com/crts/toshiba/toshiba-19a21">https://crtdatabase.com/crts/toshiba/toshiba-19a21</a>
