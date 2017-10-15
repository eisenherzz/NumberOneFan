#!/usr/bin/perl
use strict;
use warnings;
use English;
use LWP::Simple;
use XML::Simple qw(:strict);
use Data::Dumper;
use File::Path qw(make_path remove_tree);

my $client_id = "12345678";
my $artist_id = "YourName";
my $datefrom = "2017-01-01";
my $dateto = "2017-12-31";
my $condate= "$datefrom"."_$dateto";

sub getAlbumOfArtist {
	my $url =
"https://api.jamendo.com/v3.0/albums/?client_id=$client_id&format=xml&datebetween=$condate&limit=all&artist_id=@_";
	print "getting album(s) of artist @_ from Jamendo \n";
	my $response = get $url;
	die "Error getting $url" unless defined $response;

	my $xml    = new XML::Simple( KeyAttr => {album => 'id'} );
	my $data   = $xml->XMLin($response, ForceArray => ['album']);
	my @albums = ();

	foreach my $albums ( keys %{ $data->{results}->{albums}->{album} } ) {
		push( @albums, $albums );
		print "ALBUMS : " . $albums . "\n";
	}

	#print Dumper($data);
	open( TXT, ">getAlbumOfArtist.txt" );
	print TXT Dumper($data);
	close TXT;

	return (@albums);
}

sub getfanOfArtistID {
	my $url =
	"https://api.jamendo.com/v3.0/users/artists/?client_id=$client_id&format=xml&limit=all&name=@_";
	print "getting starred Artists of @_ from Jamendo \n";
	my $response = get $url;
	die "Error getting $url" unless defined $response;

	my $xml    = new XML::Simple( KeyAttr =>  {artist => 'id'} );
	my $data   = $xml->XMLin($response, ForceArray => ['artist']);
	my @fanOf = ();

	foreach my $fanOfid ( keys %{ $data->{results}->{users}->{user}->{artists}->{artist} } ) {
		push( @fanOf, $fanOfid );
		print "fan of : " . $fanOfid . "\n";
	}

	#print Dumper($data);
	open( TXT, ">getfanOfArtistID.txt" );
	print TXT Dumper($data);
	close TXT;

	return (@fanOf);
}

sub downloadAlbumOfArtist {
	my $url =
	  "https://api.jamendo.com/v3.0/albums/file?client_id=$client_id&id=$_[0]";
	print "downloading album $_[0] of Artist $_[1] from Jamendo \n";
	getstore( $url, "$_[1]/$_[0].zip" );

}

#main script
my @fanOf = &getfanOfArtistID($artist_id);

foreach my $fanOf (@fanOf) {
make_path("$fanOf");
my @albums = &getAlbumOfArtist("$fanOf");
foreach (@albums) {
	print "Artist Id : " . $fanOf . " Album : " . $_ . "\n";
	&downloadAlbumOfArtist($_, $fanOf);
}
}
