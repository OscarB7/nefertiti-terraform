#!/bin/sh

# Functions ----------------------------------------------------------#

delay_start() {
  if [[ ${command} == 'buy' ]]; then
    echo "  wait for the sell process to start before..."
    sleep 60
  fi
}

# create nefertiti command
create_nefertiti_command() {
  nerfertiti_command="${nefertiti_home}/nefertiti \
    ${command:-about}"
  nerfertiti_command="${nerfertiti_command} \
    $(if [[ "$test" == 'true' ]]; then echo '--test'; fi) \
    $(if [[ "$dca" == 'true' ]]; then echo '--dca'; fi) \
    $(if [[ "$debug" == 'true' ]]; then echo '--debug'; fi) \
    $(if [[ "$strict" == 'true' ]]; then echo '--strict'; fi)"
  nerfertiti_command="${nerfertiti_command} \
    ${agg:+--agg=}${agg} \
    ${devn:+--devn=}${devn} \
    ${dip:+--dip=}${dip} \
    ${dist:+--dist=}${dist} \
    ${earn:+--earn=}${earn} \
    ${exchange:+--exchange=}${exchange} \
    ${help:+--help=}${help} \
    ${hold:+--hold=}${hold} \
    ${ignore:+--ignore=}${ignore} \
    ${market:+--market=}${market} \
    ${max:+--max=}${max} \
    ${min:+--min=}${min} \
    ${msg:+--msg=}${msg} \
    ${mult:+--mult=}${mult} \
    ${notify:+--notify=}${notify} \
    ${pip:+--pip=}${pip} \
    ${price:+--price=}${price} \
    ${quote:+--quote=}${quote} \
    ${repeat:+--repeat=}${repeat} \
    ${sandbox:+--sandbox=}${sandbox} \
    ${side:+--side=}${side} \
    ${signals:+--signals=}${signals} \
    ${size:+--size=}${size} \
    ${stoploss:+--stoploss=}${stoploss} \
    ${strategy:+--strategy=}${strategy} \
    ${top:+--top=}${top} \
    ${type:+--type=}${type} \
    ${valid:+--valid=}${valid} \
    ${volume:+--volume=}${volume}"
}

# delete spaces in nerfertiti_command
delete_white_spaces() {
  until [[ "$nerfertiti_command" == "${nerfertiti_command//  / }" ]]; do
    echo "  ..."
    nerfertiti_command="${nerfertiti_command//  / }"
  done
}

# print nefertiti command
print_nerfertiti_command() { # $1: string to be printed
  echo "`date -u '+%Y/%m/%d %H:%M:%S'` ${nerfertiti_command}"
}

# add credentials if any and run nefertiti
nefertiti_add_credentials_and_run() {
  nerfertiti_command_full="${nerfertiti_command} \
    ${api_key:+--api-key=}${api_key} \
    ${api_secret:+--api-secret=}${api_secret} \
    ${api_passphrase:+--api-passphrase=}${api_passphrase} \
    ${pushover_app_key:+--pushover-app-key=}${pushover_app_key} \
    ${pushover_user_key:+--pushover-user-key=}${pushover_user_key} \
    ${telegram_app_key:+--telegram-app-key=}${telegram_app_key} \
    ${telegram_chat_id:+--telegram-chat-id=}${telegram_chat_id}"

    ${nerfertiti_command_full}
}

# Main ----------------------------------------------------------#
if [[ ${command} == 'sleep' ]]; then
  echo 'sleeping...'
  sleep infinity
else
  echo "- delay_start"
  delay_start
  echo "- create_nefertiti_command"
  create_nefertiti_command
  echo "- delete_white_spaces"
  delete_white_spaces
  echo "- print_nerfertiti_command"
  print_nerfertiti_command
  echo "- nefertiti_add_credentials_and_run"
  nefertiti_add_credentials_and_run
fi

exit 0
