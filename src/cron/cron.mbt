pub(all) struct CronExpr {
  minutes : Array[Int]
  hours : Array[Int]
  days_of_month : Array[Int]
  has_last_day_of_month : Bool
  months : Array[Int]
  days_of_week : Array[Int]
}

pub(all) enum CronError {
  InvalidFormat(String)
  OutOfBounds(String)
} derive(Show, Eq)
