package Coxify::Image;

use strict;

use Coxify::Db;
use Coxify::Model::Image;

sub date_list {
  my %p = @_;

  my ($sql, $binds) = Coxify::Model::Image::Manager->get_objects_sql(
    select => ['created_date', 'COUNT(t1.created_date)'],
    where => [
      active => 1,
      created_date => { gt_le => [ $p{from}, $p{to} ] }
    ],
    sort_by => 'created_date DESC',
    group_by => 'created_date',
    $p{limit} ? (limit => $p{limit}) : (),
  );

  my $db = new Coxify::Db();
  my $dbh = $db->dbh;
  my $query = $dbh->selectall_arrayref($sql, {}, @{ $binds });

  my @dates = ();
  my $idx = -1;

  for my $i (0 .. scalar(@{ $query })-1) {
    my $date = $query->[$i];

    $idx = $i if ($p{today} && $p{today}->ymd eq $date->[0]);

    push @dates, {
      date => $date->[0],
      count => $date->[1],
      url => join("/", "/image", split(/-/, $date->[0])),
    };
  }

  my $lower = $idx > 2 ? $idx - 2 : 0;
  my $higher = $lower + 6;

  for my $i ($lower..$higher) {
    last unless $p{today};
    last unless @dates[$i];
    @dates[$i]->{show} = 1;
  }

  return \@dates;
}

sub year_list {
  my ($year) = @_;

  my @where = (
    active => 1,
  );

  if ($year) {
    my $from_date = new DateTime(year => $year, month => '01', day => '01');
    my $to_date = DateTime->last_day_of_month(year => $year, month => '12');
    push @where, (created_date => { gt_le => [ $from_date, $to_date ] });
  }

  my ($sql, $binds) = Coxify::Model::Image::Manager->get_objects_sql(
    select => [ "date_trunc('month', t1.created_date)",  "count(date_trunc('month', t1.created_date))" ], 
    where => \@where,
    sort_by => "date_Trunc('month', t1.created_date) ASC",
    group_by => "date_trunc('month', t1.created_date)",
  );

  my $db = new Coxify::Db();
  my $dbh = $db->dbh;
  my $query = $dbh->selectall_arrayref($sql, {}, @{ $binds });

  my @year = ();
  for my $obj (@{ $query }) {
    my ($year, $month, $day) = split(/-/, $obj->[0]);
    my $date = new DateTime(year => $year, month => $month);
    push @year, {
      month => $date,
      count => $obj->[1],
      url => join("/", "/image", $year, $month),
    };   
  }

  my %years = ();
  for my $month (@year) {
    $years{$month->{month}->year} = [] unless $years{$month->{month}->year};
    push @{ $years{$month->{month}->year} }, $month;
  }

  return \%years;
}

1;