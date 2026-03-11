import { exec, toast, moduleInfo } from 'kernelsu';

// 获取模块信息和路径
const modInfo = moduleInfo();
const MODPATH = `/data/adb/modules/${modInfo.id}`;

// 页面加载时加载配置
window.onload = async () => {
  await loadConfig();
  await updateStatus();
};

// 加载已保存的配置
async function loadConfig() {
  const keys = ['server_addr', 'local_port', 'doh_server', 'ech_domain', 'preferred_ip', 'auth_token', 'routing_mode'];
  for (const key of keys) {
    const { stdout } = await exec(`ksud module config get ${key}`);
    if (stdout.trim()) {
      document.getElementById(key).value = stdout.trim();
    }
  }
}

// 保存配置
document.getElementById('saveBtn').addEventListener('click', async () => {
  const keys = ['server_addr', 'local_port', 'doh_server', 'ech_domain', 'preferred_ip', 'auth_token', 'routing_mode'];
  for (const key of keys) {
    const value = document.getElementById(key).value.trim();
    await exec(`ksud module config set ${key} "${value}"`);
  }
  toast('配置保存成功！');
});

// 启动代理
document.getElementById('startBtn').addEventListener('click', async () => {
  const { stderr } = await exec(`${MODPATH}/scripts/start.sh start`);
  if (stderr) {
    toast(`启动失败：${stderr}`);
  } else {
    toast('代理启动成功！');
    await updateStatus();
  }
});

// 停止代理
document.getElementById('stopBtn').addEventListener('click', async () => {
  await exec(`${MODPATH}/scripts/start.sh stop`);
  toast('代理已停止！');
  await updateStatus();
});

// 更新状态显示
async function updateStatus() {
  const { stdout } = await exec(`${MODPATH}/scripts/start.sh status`);
  document.getElementById('status').textContent = `当前状态：${stdout.trim()}`;
}
