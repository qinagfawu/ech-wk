import { exec, toast, moduleInfo } from 'kernelsu';

// 模块路径（和 netproxy 一致）
const mod = moduleInfo();
const MODPATH = `/data/adb/modules/${mod.id}`;
const SCRIPT = `${MODPATH}/scripts/control.sh`;

// 加载保存的配置
async function loadConfig() {
  try {
    const { stdout } = await exec(`${SCRIPT} get_config`);
    const [srv, port, doh, ech, ip, token, mode] = stdout.split('|');
    document.getElementById('server_addr').value = srv || '';
    document.getElementById('local_port').value = port || '30000';
    document.getElementById('doh_server').value = doh || 'dns.alidns.com/dns-query';
    document.getElementById('ech_domain').value = ech || 'cloudflare-ech.com';
    document.getElementById('preferred_ip').value = ip || '';
    document.getElementById('auth_token').value = token || '';
    document.getElementById('routing_mode').value = mode || 'global';
  } catch (e) {
    toast('加载配置失败，使用默认值');
  }
}

// 保存配置
document.getElementById('saveBtn').addEventListener('click', async () => {
  const srv = document.getElementById('server_addr').value.trim();
  const port = document.getElementById('local_port').value.trim();
  const doh = document.getElementById('doh_server').value.trim();
  const ech = document.getElementById('ech_domain').value.trim();
  const ip = document.getElementById('preferred_ip').value.trim();
  const token = document.getElementById('auth_token').value.trim();
  const mode = document.getElementById('routing_mode').value.trim();

  if (!srv) {
    toast('服务端地址不能为空！');
    return;
  }

  try {
    await exec(`${SCRIPT} save "${srv}" "${port}" "${doh}" "${ech}" "${ip}" "${token}" "${mode}"`);
    toast('配置保存成功！');
  } catch (e) {
    toast(`保存失败：${e.message}`);
  }
});

// 启动代理
document.getElementById('startBtn').addEventListener('click', async () => {
  const srv = document.getElementById('server_addr').value.trim();
  if (!srv) return toast('请先填写服务端地址！');

  toast('正在启动代理...');
  try {
    await exec(`${SCRIPT} start`);
    toast('代理已后台启动！');
    updateStatus();
    loadLog();
  } catch (e) {
    toast(`启动失败：${e.message}`);
  }
});

// 停止代理
document.getElementById('stopBtn').addEventListener('click', async () => {
  toast('正在停止代理...');
  try {
    await exec(`${SCRIPT} stop`);
    toast('代理已停止！');
    updateStatus();
    loadLog();
  } catch (e) {
    toast(`停止失败：${e.message}`);
  }
});

// 更新运行状态
async function updateStatus() {
  try {
    const { stdout } = await exec(`${SCRIPT} status`);
    const statusText = stdout === 'running' ? '✅ 运行中' : '❌ 已停止';
    document.getElementById('status').textContent = `当前状态：${statusText}`;
  } catch (e) {
    document.getElementById('status').textContent = '当前状态：检测失败';
  }
}

// 加载运行日志
async function loadLog() {
  try {
    const { stdout } = await exec(`${SCRIPT} log`);
    document.getElementById('logContent').textContent = stdout || '暂无日志';
  } catch (e) {
    document.getElementById('logContent').textContent = '日志加载失败';
  }
}

// 页面初始化
window.onload = async () => {
  await loadConfig();
  await updateStatus();
  await loadLog();
  // 定时刷新状态和日志
  setInterval(updateStatus, 3000);
  setInterval(loadLog, 5000);
};
