import {
  Builder,
  WebDriver
} from 'selenium-webdriver';

import { assert } from 'chai';


const TIMEOUT_MILLISEC = 10000;

let driver: WebDriver;

describe("サンプルページ", () => {
  before(() => {
    driver = new Builder()
      .forBrowser("chrome")
      .usingServer("http://selenium-hub:4444/wd/hub")
      .build();
  });

  after(() => {
    return driver.quit();
  });

  it("タイトルを検証する", async () => {
    await driver.get("http://next-app:3000");
    const title = await driver.getTitle();
    assert.strictEqual(title, "Create Next App");
  });

  it("h1タグの中身を検証する", async () => {
    await driver.get("http://next-app:3000");
    const h1 = await driver.findElement({ tagName: 'h1' });
    const h1_text = await h1.getAttribute("innerText")
    assert.strictEqual(h1_text, "Create Next App");
  });
});
