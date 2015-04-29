
def h(html)
  CGI.escapeHTML html
end

def pr_modifications_class(pr)
  if pr.modifications > 1000
    'text-danger bold blink'
  elsif pr.modifications > 500
    'text-danger bold'
  elsif pr.modifications > 300
    'text-warning'
  else
    ''
  end
end

def pr_title_class(pr)
  if pr.days_since_last_update.to_i > 14
    'bold'
  else
    ''
  end
end
