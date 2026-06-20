fn contains(arr : Array[Int], val : Int) -> Bool {
  for i = 0; i < arr.length(); i = i + 1 {
    if arr[i] == val {
      return true
    }
  }
  return false
}

pub fn CronExpr::matches(self : CronExpr, year : Int, minute : Int, hour : Int, day_of_month : Int, month : Int, day_of_week : Int) -> Bool {
  let dim = days_in_month(year, month)
  let matches_dom = contains(self.days_of_month, day_of_month) ||
                    (self.has_last_day_of_month && day_of_month == dim)

  contains(self.minutes, minute) &&
  contains(self.hours, hour) &&
  matches_dom &&
  contains(self.months, month) &&
  contains(self.days_of_week, day_of_week)
}
