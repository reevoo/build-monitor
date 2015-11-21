require 'seasonal_fun'

class Kitten
  GIFS = {
    xmas: {
      broken: [
        'http://media.giphy.com/media/x33p3SDzDM1ji/giphy.gif',
        'https://s-media-cache-ak0.pinimg.com/originals/12/8d/c0/128dc0248ec1e0adb60ff54f330b48a1.gif',
        'http://i.imgur.com/6IMR58L.gif',
      ],
      passing: [
        'http://www.cutecatgifs.com/wp-content/uploads/2013/12/tumblr_mxd8jmQ8X71rf3vado3_400.gif',
        'http://media.giphy.com/media/HGyncAYumiU4o/giphy.gif',
      ],
    },
    nil => {
      broken: [
        "http://laughingthroughthepain.files.wordpress.com/2011/03/crazy-cat.gif",
        "http://25.media.tumblr.com/48e94e1a869a0077d73444d1c528d636/tumblr_mhyuefmaUn1rkp3avo1_500.gif"
      ],
      passing: [
        'http://1-ps.googleusercontent.com/h/www.catgifpage.com/gifs/224.gif.pagespeed.ce.8Ox__cf1NE.gif',
        'http://1-ps.googleusercontent.com/h/www.catgifpage.com/gifs/223.gif.pagespeed.ce.74u-hdg7bt.gif',
        'http://stream1.gifsoup.com/view/437149/roomba-kittens-o.gif',
      ],
    }
  }

  def self.url(state)
    GIFS[SeasonalFun.season][state].sample
  end
end
