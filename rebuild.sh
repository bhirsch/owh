#!/bin/bash
#
# This command expects to be run within the O profile directory. 
#
# To use this command you must have `drush make`, `cvs` and `git` installed.
#
# Original script by Jeff Miccolis for Open Atrium.
#

if [ -f owh.make ]; then
  echo -e "\nThis command can be used to run o.make in place, or to generate"
  echo -e "a complete distribution of Drupal O.\n\nWhich would you like?"
  echo "  [1] Rebuild Drupal O in place (overwrites any changes!)."
  echo "  [2] (BROKEN) Build a full Drupal O distribution"
  echo -e "Selection: \c"
  read SELECTION

  if [ $SELECTION = "1" ]; then

    # Run o.make only.
    echo "Building Drupal O install profile..."
    rm -Rf modules/ themes/ libraries/
    drush -y make --working-copy --no-core --contrib-destination=. o.make

  elif [ $SELECTION = "2" ]; then

    # Generate a complete tar.gz of Pressflow Drupal + O.
    echo "Building Drupal O distribution..."

MAKE=$(cat <<EOF
core = "6.x"\n
api = 2\n
projects[pressflow][type] = "core"
projects[pressflow][download][url] = "http://launchpad.net/pressflow/6.x/6.19.92/+download/pressflow-6.19.92.tar.gz"
projects[pressflow][download][type] = "get"
projects[owh][type] = "profile"\n
projects[owh][download][type] = "git"\n
projects[owh][download][url] = "git://github.com/bhirsch/owh.git"\n
EOF
)

     TAG=`cvs status o.make | grep "Sticky Tag:" | awk '{print $3}'`
    if [ -n $TAG ]; then
      if [ $TAG = "(none)" ]; then
        TAG="HEAD"
        VERSION="head"
      elif [ $TAG = "HEAD" ]; then
        VERSION="head"
      else
        # Convert 1-1-BETA6 into 1.1-BETA6
        VERSION=`echo ${TAG:10} | sed s/"\([0-9]\)-\([0-9]\)"/"\1.\2"/`
      fi
      MAKE="$MAKE $TAG\n"
      NAME=`echo "managingnews-$VERSION" | tr '[:upper:]' '[:lower:]'`
      echo -e $MAKE | drush make --yes - $NAME
      zip -r $NAME.zip $NAME
    else
      echo 'Could not determine CVS tag. Is o.make a CVS checkout?'
    fi
  else
   echo "Invalid selection."
  fi
else
  echo 'Could not locate file "o.make"'
fi
