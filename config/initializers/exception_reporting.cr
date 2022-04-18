  
# def catch_and_report_exception(options = {})
#   begin
#     yield
#     nil
#   rescue options.fetch(:class) { StandardError } => e
#     report_exception(e)
#     e
#   end
# end

# report_api_error sample output.
# With default Rails formatter:
# I, [2019-09-18T12:52:59.077389 #157366]  INFO -- : {:message=>"Account balance is insufficient", :path=>"/api/v2/account/withdraws", :params=>{"uid"=>"ID20DA7496BB", "currency"=>"usd", "amount"=>0.1e3, "beneficiary_id"=>1, "otp"=>123456}}
#
# With JSONLogFormatter:
# {"message":"Account balance is insufficient","path":"/api/v2/account/withdraws","params":{"uid":"ID5DE7A981C4","currency":"usd","amount":"100.0","beneficiary_id":1,"otp":123456},"level":"INFO","time":"2019-09-18 12:54:36"}

def report_api_error(exception, request, params)
  Log.info { { message: exception.message, path: request.path, params: params } }
end

def report_exception(exception, report_to_ets = true)
  report_exception_to_screen(exception)
  # report_exception_to_ets(exception) if report_to_ets
end

def report_exception_to_screen(exception)
  Log.info { exception.inspect }
  Log.info { exception.backtrace.join("\n") } if exception.backtrace?
end

# def report_exception_to_ets(exception)
#   Raven.capture_exception(exception) if defined?(Raven)
# rescue => ets_exception
#   report_exception(ets_exception, false)
# end
