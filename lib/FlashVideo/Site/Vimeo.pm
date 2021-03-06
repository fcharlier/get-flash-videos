# Part of get-flash-videos. See get_flash_videos for copyright.
package FlashVideo::Site::Vimeo;

use strict;
use warnings;
use FlashVideo::Utils;
use FlashVideo::JSON;

sub find_video {
  my ($self, $browser, $embed_url) = @_;

  my $id;
  if ($embed_url =~ /clip_id=(\d+)/) {
    $id = $1;
  } elsif ($embed_url =~ m!/(\d+)!) {
    $id = $1;
  }
  die "No ID found\n" unless $id;

  my $sig = ($browser->content =~ /"signature":"(\w+)"/)[0];
  my $time = ($browser->content =~ /"timestamp":([0-9]+)/)[0];
  my $quality = ($browser->content =~ /"videoQuality" content="([A-Z]+)"/)[0];
  $quality = lc $quality;

  # Use the embed api to get the correctly formatted title of the video
  my $info_url = "http://vimeo.com/api/oembed.json?url=http://vimeo.com/$id";
  $browser->get($info_url);
  my $video_data = from_json($browser->content);
  my $title = $video_data->{title};

  debug "id: $id \n" .
        "sig: $sig \n" .
        "time: $time \n" .
        "quality: $quality \n" .
        "title: $title \n";

  my $url = "http://player.vimeo.com/play_redirect?" .
            "clip_id=$id&sig=$sig&time=$time&quality=$quality" .
            "&codecs=H264,VP8,VP6&type=moogaloop_local&embed_location=";
  my $filename = title_to_filename($title, "flv");

  $browser->allow_redirects;

  return $url, $filename;
}

1;
