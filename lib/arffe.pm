package arffe;
use Dancer ':syntax';
use Email::Report::ARF qw( getcontact );

our $VERSION = '0.1';

get '/' => sub {
    template 'input';
};

post '/spam' => sub {
    unless ( params->{mail} ) {
        redirect '/';
    }


    my $report = Email::Report::ARF->new(
        mail => params->{mail},
        'Feedback-Type' => 'abuse',
#        debug => 1,
        as  => 'spamfeed-me',
    );

    unless ($report) {
        redirect '/';
    }

    $report->munge();
#    $report->addrcpt( 'foo@bar.de' );
    $report->addrcpt( Email::Report::ARF::getcontact( $report->{'Source-IP'}) );
    $report->arf();

    my $mail = $report->report_asmail( from => 'your@email.com' );
    if ($mail) {
       template 'output', {  data => $mail->string };

    } else {
        redirect '/';
    }


};

true;
