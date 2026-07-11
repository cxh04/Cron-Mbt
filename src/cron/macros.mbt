///|
pub fn expand_macro(expr : String) -> String {
  match expr {
    "@yearly" => "0 0 1 1 *"
    "@annually" => "0 0 1 1 *"
    "@monthly" => "0 0 1 * *"
    "@weekly" => "0 0 * * 0"
    "@daily" => "0 0 * * *"
    "@midnight" => "0 0 * * *"
    "@hourly" => "0 * * * *"
    _ => expr
  }
}
