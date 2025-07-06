import 'package:flutter/material.dart';

import 'installation_wizard/installation_wizard_controller.dart';
import 'installation_wizard/installation_wizard_models.dart';
import 'installation_wizard/wizard_steps/config_step.dart';
import 'installation_wizard/wizard_steps/analysis_step.dart';
import 'installation_wizard/wizard_steps/execution_step.dart';
import 'home_page.dart';

/// 新的安装向导页面
class InstallationWizardPageNew extends StatefulWidget {
  const InstallationWizardPageNew({super.key});

  /// 检查是否有正在进行的安装
  static bool get hasActiveInstallation => InstallationWizardController.hasActiveInstallation;

  /// 检查是否正在安装
  static bool get isInstalling => InstallationWizardController.isInstalling;

  @override
  State<InstallationWizardPageNew> createState() => _InstallationWizardPageNewState();
}

class _InstallationWizardPageNewState extends State<InstallationWizardPageNew> {
  final PageController _pageController = PageController();
  late InstallationWizardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InstallationWizardController();
    _controller.initialize();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
    
    // 自动切换页面
    if (_controller.state.currentStep.index != _pageController.page?.round()) {
      _pageController.animateToPage(
        _controller.state.currentStep.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    
    // 移除自动步骤切换，让用户手动控制
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        appBar: AppBar(
          title: const Text('安装向导'),
          automaticallyImplyLeading: true,
        ),
        body: Column(
          children: [
            // 步骤指示器
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildStepIndicator(WizardStep.configure, '配置', '必需'),
                  _buildStepConnector(),
                  _buildStepIndicator(WizardStep.analyze, '分析', '自动'),
                  _buildStepConnector(),
                  _buildStepIndicator(WizardStep.options, '选项', '可选'),
                  _buildStepConnector(),
                  _buildStepIndicator(WizardStep.execute, '执行', '完成'),
                ],
              ),
            ),
            
            // 页面内容
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ConfigStep(controller: _controller),
                  AnalysisStep(controller: _controller),
                  _buildOptionsStep(), // 选项步骤
                  ExecutionStep(controller: _controller),
                ],
              ),
            ),
            
            // 底部按钮
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_controller.state.currentStep.index > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _controller.state.isAutoAdvancing ? null : _getPreviousButtonAction(),
                        child: const Text('上一步'),
                      ),
                    ),
                  if (_controller.state.currentStep.index > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _getNextButtonAction(),
                      child: Text(_getNextButtonText()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  // 构建步骤指示器
  Widget _buildStepIndicator(WizardStep step, String title, String subtitle) {
    final isActive = step.index <= _controller.state.currentStep.index;
    final isCurrent = step == _controller.state.currentStep;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
              border: isCurrent ? Border.all(color: Colors.blue, width: 2) : null,
            ),
            child: Center(
              child: Text(
                '${step.index + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.blue : Colors.grey[600],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // 构建步骤连接器
  Widget _buildStepConnector() {
    return Container(
      width: 40,
      height: 2,
      color: Colors.grey[300],
      margin: const EdgeInsets.only(bottom: 40),
    );
  }

  // 构建选项步骤
  Widget _buildOptionsStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '安装选项',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _controller.state.needsAdditionalInstall 
              ? '需要配置额外的安装选项'
              : '使用默认安装选项',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          if (_controller.state.needsAdditionalInstall) ...[
            // 安装类型选择
            Text(
              '安装源类型',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            RadioListTile<String>(
              title: const Text('GitHub仓库'),
              subtitle: const Text('从GitHub仓库安装'),
              value: 'github',
              groupValue: _controller.state.selectedInstallType,
              onChanged: (value) {
                if (value != null) {
                  _controller.updateSelectedInstallType(value);
                }
              },
            ),
            
            RadioListTile<String>(
              title: const Text('本地路径'),
              subtitle: const Text('从本地路径安装'),
              value: 'local',
              groupValue: _controller.state.selectedInstallType,
              onChanged: (value) {
                if (value != null) {
                  _controller.updateSelectedInstallType(value);
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // 根据选择显示不同的配置选项
            if (_controller.state.selectedInstallType == 'github') ...[
              TextField(
                onChanged: _controller.updateGithubUrl,
                decoration: const InputDecoration(
                  labelText: 'GitHub仓库URL',
                  hintText: 'https://github.com/user/repo.git',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
              ),
            ] else if (_controller.state.selectedInstallType == 'local') ...[
              TextField(
                onChanged: _controller.updateLocalPath,
                decoration: InputDecoration(
                  labelText: '本地路径',
                  hintText: '/path/to/mcp-server',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.folder),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () {
                      // TODO: 实现文件夹选择
                    },
                  ),
                ),
              ),
            ],
          ] else ...[
            // 自动安装提示
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_mode, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '自动安装',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '系统将自动处理安装过程，无需额外配置',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 获取上一步按钮操作
  VoidCallback? _getPreviousButtonAction() {
    // 如果当前在安装步骤且正在安装中，需要确认取消
    if (_controller.state.currentStep == WizardStep.execute && _controller.state.isInstalling) {
      return () async {
        final shouldCancel = await _controller.showCancelInstallDialog(context);
        if (shouldCancel == true) {
          _controller.cancelInstallation();
          _controller.previousStep();
        }
      };
    }
    
    return _controller.previousStep;
  }

  // 获取下一步按钮操作
  VoidCallback? _getNextButtonAction() {
    if (_controller.state.isAutoAdvancing) {
      return null;
    }
    
    switch (_controller.state.currentStep) {
      case WizardStep.configure:
        return _controller.state.parsedConfig.isNotEmpty && _controller.state.configError.isEmpty 
          ? () {
              _controller.nextStep();
              _controller.parseConfig(); // 触发分析
            }
          : null;
      case WizardStep.analyze:
        return _controller.nextStep;
      case WizardStep.options:
        return _controller.validateInstallOptions() ? _controller.nextStep : null;
      case WizardStep.execute:
        return _controller.state.installationSuccess 
          ? _finishWizard 
          : (_controller.state.isInstalling ? null : _controller.startInstallation);
    }
  }

  String _getNextButtonText() {
    switch (_controller.state.currentStep) {
      case WizardStep.configure:
        return '分析配置';
      case WizardStep.analyze:
        return '下一步';
      case WizardStep.options:
        return '开始安装';
      case WizardStep.execute:
        return _controller.state.installationSuccess 
          ? '完成' 
          : (_controller.state.isInstalling ? '安装中...' : '开始安装');
    }
  }

  void _finishWizard() {
    _controller.clearState();
    
    // 检查是否是从导航推送进来的（有返回按钮）
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(_controller.state.installationSuccess);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }
} 