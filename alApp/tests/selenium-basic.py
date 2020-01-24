#!/usr/bin/python
import sys
import unittest
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities

driver = webdriver.Remote(
  command_executor='http://localhost:4444/wd/hub',
  desired_capabilities=DesiredCapabilities.CHROME)

driver.get(sys.argv[1])
assert "Todo" in driver.title
driver.find_element_by_id("todo-list")

driver.close
